#' @export
box_pkg_fun_exists_linter <- function() {
  box_base_path <- "
  //SYMBOL_PACKAGE[
    text() = 'box' and
    following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use']
  ]
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
