#' Box library universal import linter
#'
#' Checks that all function imports are explicit. `package[...]` is not used.
#'
#' @param exclude Exclude package names. Defaults are `shiny` and `testthat`.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(base[...])",
#'   linters = box_universal_import_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/file[...])",
#'   linters = box_universal_import_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(base[print])",
#'   linters = box_universal_import_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/file[do_something])",
#'   linters = box_universal_import_linter()
#' )
#'
#' @export
box_universal_import_linter <- function(exclude = c("shiny", "testthat")) {
  lint_message <- "Explicitly declare imports rather than universally import with `...`."

  xpath_exclude_packages <- NULL

  if (!is.null(exclude)) {
    exclude_packages <- glue::glue_collapse(
      glue::glue("text() != '{exclude}'"),
      sep = " and "
    )

    xpath_exclude_packages <- glue::glue("parent::expr
                                         /preceding-sibling::expr[SYMBOL[{exclude_packages}]]")
  }

  xpath_symbol_selector <- glue::glue_collapse(
    c("text() = '...'",
      xpath_exclude_packages),
    sep = " and "
  )

  xpath <- glue::glue("
  //SYMBOL_PACKAGE[(text() = 'box' and
        following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  //SYMBOL[{xpath_symbol_selector}]
  ")

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
