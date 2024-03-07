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
    OP-LEFT-BRACKET
  ]
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
  
  box_package_import <- "
  /child::expr[
    SYMBOL
  ]
  "
  
  box_package_import_all <- "
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
  xpath_package_import_all <- paste(box_base_path, box_package_import_all)
  
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
  
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }
    
    xml <- source_expression$full_xml_parsed_content
    
    imported_functions <- get_imported_functions(xml, xpath_package_functions)
    imported_all_fun_pkgs <- get_imported_package_functions(xml, xpath_package_import_all)
    
    imported_fun_text <- c(imported_functions$text, imported_all_fun_pkgs$text)
    
    imported_packages <- xml2::xml_find_all(xml, xpath_package_import)
    imported_packages_text <- xml2::xml_text(imported_packages)
    imported_package_functions <- get_packages_exports(imported_packages_text)
    names(imported_package_functions) <- imported_packages_text
    
    imported_package_function_list <- unlist(
      lapply(names(imported_package_functions), function(pkg) {
        paste(
          pkg,
          imported_package_functions[[pkg]],
          sep = "$"
        )
      })
    )
    
    # get list of function calls
    function_calls <- xml2::xml_find_all(xml, xpath_box_function_calls)
    function_calls_text <- xml2::xml_text(function_calls)
    
    # remove base function calls
    
    # compare lists
    # setdiff(imported_functions, function_calls)
    
    unimported_functions <- lapply(function_calls, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)
      
      if (grepl(".+\\$.+", fun_call_text)) {
        if (!fun_call_text %in% imported_package_function_list) {
          lintr::xml_nodes_to_lints(
            fun_call,
            source_expression = source_expression,
            lint_message = "package$function does not exist.",
            type = "warning"
          )
        }
      } else {
        if (!fun_call_text %in% imported_fun_text) {
          lintr::xml_nodes_to_lints(
            fun_call,
            source_expression = source_expression,
            lint_message = "Function not imported.",
            type = "warning"
          )
        }
      }
    })
    
    unused_function_imports <- lapply(imported_functions$xml, function(fun_import) {
      fun_import_text <- xml2::xml_text(fun_import)
      fun_import_text <- gsub("`", "", fun_import_text)
      
      if (!fun_import_text %in% function_calls_text) {
        lintr::xml_nodes_to_lints(
          fun_import,
          source_expression = source_expression,
          lint_message = "Imported function unused.",
          type = "warning"
        )
      }
    })
    
    c(
      unimported_functions,
      unused_function_imports
    )
  })
}

get_packages_exports <- function(pkg_list) {
  lapply(pkg_list, function(pkg) {
    tryCatch(
      getNamespaceExports(pkg),
      error = function(e) character()
    )
  })
}

get_imported_functions <- function(xml, xpath_package_functions) {
  imported_functions <- xml2::xml_find_all(xml, xpath_package_functions)
  imported_functions_text <- xml2::xml_text(imported_functions)
  # remove back-ticks "`%>%`" -> "%>%"
  imported_functions_text <- gsub("`", "", imported_functions_text)
  
  list(
    xml = imported_functions,
    text = imported_functions_text
  )
}

get_imported_package_functions <- function(xml, xpath_package_import_all) {
  imported_all_functions_package <- xml2::xml_find_all(xml, xpath_package_import_all)
  imported_all_fun_pkg_text <- xml2::xml_text(imported_all_functions_package)
  imported_all_fun_pkgs <- unlist(
    get_packages_exports(imported_all_fun_pkg_text)
  )
  
  list(
    xml = imported_all_functions_package,
    text = imported_all_fun_pkgs
  )
}