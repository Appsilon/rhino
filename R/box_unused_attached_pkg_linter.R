#' @export
box_unused_attached_pkg_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_packages <- get_attached_packages(xml)
    attached_three_dots <- get_attached_three_dots(xml)
    function_calls <- get_function_calls(xml)

    unused_package <- lapply(attached_packages$xml, function(attached_package) {
      package_text <- lintr::get_r_string(attached_package)

      func_list <- paste(package_text, attached_packages$nested[[package_text]], sep = "$")

      functions_used <- length(intersect(func_list, function_calls$text))

      if (functions_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_package,
          source_expression = source_expression,
          lint_message = "Attached package unused.",
          type = "warning"
        )
      }
    })

    unused_three_dots <- lapply(attached_three_dots$xml, function(attached_package) {
      package_text <- lintr::get_r_string(attached_package)

      func_list <- attached_three_dots$nested[[package_text]]

      functions_used <- length(intersect(func_list, function_calls$text))

      if (functions_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_package,
          source_expression = source_expression,
          lint_message = "Three-dots attached package unused.",
          type = "warning"
        )
      }
    })

    c(
      unused_package,
      unused_three_dots
    )
  })
}
