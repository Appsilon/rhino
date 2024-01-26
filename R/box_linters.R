#' Box library separate packages and module imports linter
#'
#' Checks that packages and modules are imported in separate `box::use()` statements.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(package, path/to/file)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/file, package)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(package1, package2)
#'     box::use(path/to/file1, path/to/file2)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' @export
box_separate_calls_linter <- function() {
  xpath <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    ./child::expr[child::SYMBOL] and
    ./child::expr[child::expr[child::OP-SLASH]]
  ]
  "
  lint_message <- "Separate packages and modules in their respective box::use() calls."

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

#' Box library universal import linter
#'
#' Checks that all function imports are explicit. `package[...]` is not used.
#'
#' @return A custom linter function for use with `r-lib/lintr`
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
box_universal_import_linter <- function() {
  lint_message <- "Explicitly declare imports rather than universally import with `...`."

  xpath <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
    /parent::expr
    /parent::expr
    //SYMBOL[text() = '...']
  "

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
