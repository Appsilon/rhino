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
  /expr/SYMBOL[
    preceding::OP-LEFT-BRACKET and
    following::OP-RIGHT-BRACKET
  ]
  "
  
  xpath_package_functions <- paste(box_base_path, box_package_functions)
  
  xpath_function_calls <- "
  //SYMBOL_FUNCTION_CALL[
    not(
      preceding-sibling::SYMBOL_PACKAGE[text() = 'box'] and
      text() = 'use'
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
    
    # get list of function calls
    function_calls <- xml2::xml_find_all(xml, xpath_function_calls)
    function_calls_text <- xml2::xml_text(function_calls)
    
    # remove base function calls
    
    # compare lists
    # setdiff(imported_functions, function_calls)
    
    unimported_functions <- lapply(function_calls, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)
      
      if (!fun_call_text %in% imported_functions_text) {
        lintr::xml_nodes_to_lints(
          fun_call,
          source_expression = source_expression,
          lint_message = "Function not imported.",
          type = "warning"
        )
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