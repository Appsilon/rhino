#' @export
box_pkg_fun_exists_linter <- function() {
  box_base_path <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  "

  box_package_functions <- "
  /child::expr[
    expr/SYMBOL and
    OP-LEFT-BRACKET and
    not(
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        SYMBOL[
          text() = '...'
        ]
      ]
    )
  ]
  "

  xpath_package_functions <- paste(box_base_path, box_package_functions)

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    pkg_fun_not_exists <- check_attached_pkg_funs(xml, xpath_package_functions)

    lapply(pkg_fun_not_exists$xml, function(xml_node) {
      lintr::xml_nodes_to_lints(
        xml_node,
        source_expression = source_expression,
        lint_message = "Function not exported by package.",
        type = "warning"
      )
    })
  })
}

#' @export
box_usage_linter <- function() {
  box_base_path <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  "

  box_package_functions <- "
  /child::expr[
    expr/SYMBOL and
    OP-LEFT-BRACKET and
    not(
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        SYMBOL[
          text() = '...'
        ]
      ]
    )
  ]
  "

  box_package_import <- "
  /child::expr[
    SYMBOL
  ]
  "

  box_package_three_dots <- "
  /child::expr[
    expr/SYMBOL[text() = '...']
  ]
  /expr[
    following-sibling::OP-LEFT-BRACKET
  ]
  /SYMBOL
  "

  xpath_package_functions <- paste(box_base_path, box_package_functions)
  xpath_package_import <- paste(box_base_path, box_package_import)
  xpath_package_three_dots <- paste(box_base_path, box_package_three_dots)

  xpath_box_function_calls <- "
  //expr[
    SYMBOL_FUNCTION_CALL[
      not(text() = 'use')
    ] and
    not(
      SYMBOL_PACKAGE[text() = 'box']
    )
  ] |
  //SPECIAL
  "

  xpath_function_assignment <- "
  //expr[
      (LEFT_ASSIGN or EQ_ASSIGN) and ./expr[2][FUNCTION or OP-LAMBDDA]
    ]
    /expr[1]/SYMBOL
  | //expr_or_assign_or_help[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //equal_assign[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //SYMBOL_FUNCTION_CALL[text() = 'assign']/parent::expr[
      ./following-sibling::expr[2][FUNCTION or OP-LAMBDA]
    ]
    /following-sibling::expr[1]/STR_CONST
  "

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_functions <- get_attached_functions(xml, xpath_package_functions)
    attached_three_dots <- get_attached_three_dots(xml, xpath_package_three_dots)
    all_attached_fun <- c(attached_functions$text, attached_three_dots$text)

    fun_assignments <- extract_xml_and_text(xml, xpath_function_assignment)
    all_known_fun <- c(all_attached_fun, fun_assignments$text)

    attached_packages <- get_attached_packages(xml, xpath_package_import)
    function_calls <- get_function_calls(xml, xpath_box_function_calls)
    base_pkgs <- get_base_packages()

    unimported_functions <- lapply(function_calls$xml_nodes, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)

      if (!fun_call_text %in% base_pkgs$text) {
        if (grepl(".+\\$.+", fun_call_text)) {
          if (!fun_call_text %in% attached_packages$text) {
            lintr::xml_nodes_to_lints(
              fun_call,
              source_expression = source_expression,
              lint_message = "package$function does not exist.",
              type = "warning"
            )
          }
        } else {
          if (!fun_call_text %in% all_known_fun) {
            lintr::xml_nodes_to_lints(
              fun_call,
              source_expression = source_expression,
              lint_message = "Function not imported.",
              type = "warning"
            )
          }
        }
      }
    })

    unused_function_imports <- lapply(attached_functions$xml, function(fun_import) {
      fun_import_text <- xml2::xml_text(fun_import)
      fun_import_text <- gsub("[`'\"]", "", fun_import_text)

      if (!fun_import_text %in% function_calls$text) {
        lintr::xml_nodes_to_lints(
          fun_import,
          source_expression = source_expression,
          lint_message = "Imported function unused.",
          type = "warning"
        )
      }
    })

    unused_function_assign <- lapply(fun_assignments$xml_nodes, function(fun_assign) {
      fun_assign_text <- xml2::xml_text(fun_assign)
      fun_assign_text <- gsub("[`'\"]", "", fun_assign_text)

      if (!fun_assign_text %in% function_calls$text) {
        lintr::xml_nodes_to_lints(
          fun_assign,
          source_expression = source_expression,
          lint_message = "Declared function unused.",
          type = "warning"
        )
      }
    })

    c(
      unimported_functions,
      unused_function_imports,
      unused_function_assign
    )
  })
}

check_attached_pkg_funs <- function(xml, xpath) {
  pkg_imports <- xml2::xml_find_all(xml, xpath)

  xpath_pkg_names <- "
    expr/SYMBOL[
      parent::expr/following-sibling::OP-LEFT-BRACKET
    ]"

  xpath_just_functions <- "
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        following-sibling::OP-RIGHT-BRACKET
      ]
      /SYMBOL[
        not(
          text() = '...'
        )
      ]
    "

  not_exported <- lapply(pkg_imports, function(pkg_import) {
    xml2::xml_find_all(pkg_import, xpath_just_functions)

    packages <- extract_xml_and_text(pkg_import, xpath_pkg_names)
    exported_functions <- unlist(get_packages_exports(packages$text))
    attached_functions <- extract_xml_and_text(pkg_import, xpath_just_functions)

    attached_functions$xml[!attached_functions$text %in% exported_functions]
  })

  list(
    xml = not_exported
  )
}

get_packages_exports <- function(pkg_list) {
  exported_funs <- lapply(pkg_list, function(pkg) {
    tryCatch(
      getNamespaceExports(pkg),
      error = function(e) character()
    )
  })

  names(exported_funs) <- pkg_list

  exported_funs
}

extract_xml_and_text <- function(xml, xpath) {
  xml_nodes <- xml2::xml_find_all(xml, xpath)
  text <- lintr::get_r_string(xml_nodes)
  text <- gsub("[`'\"]", "", text)

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

get_attached_functions <- function(xml, xpath) {
  xpath_just_functions <- "
  /expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL[
    not(
      text() = '...'
    )
  ]
"

  xpath_attached_functions <- paste(xpath, xpath_just_functions)
  attached_functions <- extract_xml_and_text(xml, xpath_attached_functions)

  list(
    xml = attached_functions$xml_nodes,
    text = attached_functions$text
  )
}

get_attached_three_dots <- function(xml, xpath) {
  attached_three_dots <- extract_xml_and_text(xml, xpath)

  nested_list <- get_packages_exports(attached_three_dots$text)
  flat_list <- unlist(nested_list, use.names = FALSE)

  list(
    xml = attached_three_dots$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}

get_attached_packages <- function(xml, xpath) {
  attached_packages <- extract_xml_and_text(xml, xpath)

  nested_list <- get_packages_exports(attached_packages$text)

  flat_list <- unlist(
    lapply(names(nested_list), function(pkg) {
      paste(
        pkg,
        nested_list[[pkg]],
        sep = "$"
      )
    })
  )

  list(
    xml = nested_list$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}

get_base_packages <- function() {
  base_pkgs_names <- utils::sessionInfo()$basePkgs
  base_pkgs_funs <- get_packages_exports(base_pkgs_names)
  base_pkgs_funs_flat <- unlist(base_pkgs_funs, use.names = FALSE)

  list(
    nested = base_pkgs_funs,
    text = base_pkgs_funs_flat
  )
}

get_function_calls <- function(xml, xpath) {
  # lintr::get_r_string throws an error when seeing SYMBOL %>%
  xml_nodes <- xml2::xml_find_all(xml, xpath)
  text <- xml2::xml_text(xml_nodes, trim = TRUE)
  r6_refs <- internal_r6_refs(text)

  xml_nodes <- xml_nodes[!r6_refs]
  text <- text[!r6_refs]

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

internal_r6_refs <- function(func_list) {
  r6_refs <- "self|private\\$.+"
  grepl(r6_refs, func_list)
}
