box_alphabetical_imports <- function() {
  xpath_base <- "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
/parent::expr
/parent::expr"
  
  xpath <- paste(xpath_base, "
/child::expr[
  descendant::SYMBOL
]")
  
  xpath_modules <- "child::expr[1]/SYMBOL | child::SYMBOL"
  
  lint_message <- "Must be alphabetical."
  
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }
    
    xml <- source_expression$xml_parsed_content
    
    xml_root <- xml2::xml_find_all(xml, xpath_base)
    
    xml_nodes <- xml2::xml_find_all(xml, xpath)
    
    modules_called <- xml2::xml_text(
      xml2::xml_find_all(xml_nodes, xpath_modules)
    )
    
    if (!all(modules_called == sort(modules_called))) {
      lintr::xml_nodes_to_lints(
        xml_root,
        source_expression = source_expression,
        lint_message = lint_message,
        type = "style"
      )
    }
  })
}
