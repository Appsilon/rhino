#' @export
unused_declared_func_linter <- function() {
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

    fun_assignments <- extract_xml_and_text(xml, xpath_function_assignment)

    function_calls <- get_function_calls(xml, xpath_box_function_calls)

    lapply(fun_assignments$xml_nodes, function(fun_assign) {
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
  })
}
