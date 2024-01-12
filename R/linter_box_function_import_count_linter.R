#' Box library function import count linter
#'
#' Checks that function imports do not exceed the defined `max`.
#'
#' @param max Maximum function imports allowed between `[` and `]`. Defaults to 8.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four, five, six, ])",
#'   linters = box_func_import_count_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four, ])",
#'   linters = box_func_import_count_linter(3)
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four, five, ])",
#'   linters = box_func_import_count_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[one, two, three, ])",
#'   linters = box_func_import_count_linter(3)
#' )
#'
#' @export
box_func_import_count_linter <- function(max = 8L) {
  xpath <- glue::glue("//SYMBOL_PACKAGE[
                      (text() = 'box' and
                      following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])
                    ]
/parent::expr
/parent::expr
/descendant::OP-LEFT-BRACKET[
  count(
    following-sibling::expr[
      count(. | ..//OP-RIGHT-BRACKET/preceding-sibling::expr) =
        count(../OP-RIGHT-BRACKET/preceding-sibling::expr)
    ]
  ) > {max}
]
/parent::expr")

  lint_message <- glue::glue("Limit the function imports to a max of {max}.")

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    bad_expr <- xml2::xml_find_all(xml, xpath)

    lintr::xml_nodes_to_lints(
      bad_expr,
      source_expression = source_expression,
      lint_message = lint_message,
      type = "style"
    )
  })
}
