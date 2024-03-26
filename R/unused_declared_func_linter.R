#' @export
unused_declared_func_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    fun_assignments <- get_declared_functions(xml)
    function_calls <- get_function_calls(xml)

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
