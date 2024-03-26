#' @export
box_unused_attached_fun_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_functions <- get_attached_functions(xml)
    function_calls <- get_function_calls(xml)

    lapply(attached_functions$xml, function(fun_import) {
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
  })
}
