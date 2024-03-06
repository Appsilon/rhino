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
  /SYMBOL
  "
  
  box_package_import <- "
  /child::expr[
    SYMBOL
  ]
  "

  xpath_package_functions <- paste(box_base_path, box_package_functions)
  xpath_package_import <- paste(box_base_path, box_package_import)
  
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

    # get list of imported package functions
    imported_functions <- xml2::xml_find_all(xml, xpath_package_functions)
    imported_functions_text <- xml2::xml_text(imported_functions)
    # remove back-ticks "`%>%`" -> "%>%"
    imported_functions_text <- gsub("`", "", imported_functions_text)
    
    imported_packages <- xml2::xml_find_all(xml, xpath_package_import)
    imported_packages_text <- xml2::xml_text(imported_packages)
    imported_package_functions <- lapply(imported_packages_text, function(pkg) {
        tryCatch(
          getNamespaceExports(pkg),
          error = function(e) character()
        )
      })
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
        if (!fun_call_text %in% imported_functions_text) {
          lintr::xml_nodes_to_lints(
            fun_call,
            source_expression = source_expression,
            lint_message = "Function not imported.",
            type = "warning"
          )
        }
      }
    })
    
    unused_function_imports <- lapply(imported_functions, function(fun_import) {
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
