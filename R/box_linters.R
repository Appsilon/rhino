# nolint start: line_length_linter
#' `box` library alphabetical module and function imports linter
#'
#' Checks that module and function imports are sorted alphabetically. Aliases are
#' ignored. The sort check is on package/module names and attached function names.
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(packageB, packageA)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[functionB, functionA])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/B, path/to/A)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionB, functionA])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[alias = functionB, functionA])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(packageA, packageB)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[one, two, three])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[functionA, functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#' 
#' lintr::lint(
#'   text = "box::use(path/to/A, path/to/B)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionA, functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionA, alias = functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' @export
# nolint end
box_alphabetical_calls_linter <- function() {
  xpath_base <- "//SYMBOL_PACKAGE[(text() = 'box' and 
  following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr"

  xpath <- paste(xpath_base, "
  /child::expr[
    descendant::SYMBOL
  ]")

  xpath_modules_with_functions <- paste(xpath_base, "
  /child::expr[
    descendant::SYMBOL and
    descendant::OP-LEFT-BRACKET
  ]")

  xpath_functions <- "./descendant::expr/SYMBOL[
    ../preceding-sibling::OP-LEFT-BRACKET and
    ../following-sibling::OP-RIGHT-BRACKET
  ]"

  lint_message <- "Module and function imports must be sorted alphabetically."

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content
    xml_nodes <- xml2::xml_find_all(xml, xpath)
    modules_called <- xml2::xml_text(xml_nodes)
    modules_check <- modules_called == sort(modules_called)

    unsorted_modules <- which(modules_check == FALSE)
    module_lint <- lintr::xml_nodes_to_lints(
      xml_nodes[unsorted_modules],
      source_expression = source_expression,
      lint_message = lint_message,
      type = "style"
    )

    xml_nodes_with_functions <- xml2::xml_find_all(xml_nodes, xpath_modules_with_functions)

    function_lint <- lapply(xml_nodes_with_functions, function(xml_node) {
      imported_functions <- xml2::xml_find_all(xml_node, xpath_functions)
      functions_called <- xml2::xml_text(imported_functions)
      functions_check <- functions_called == sort(functions_called)
      unsorted_functions <- which(functions_check == FALSE)

      lintr::xml_nodes_to_lints(
        imported_functions[unsorted_functions],
        source_expression = source_expression,
        lint_message = lint_message,
        type = "style"
      )
    })

    c(module_lint, function_lint)
  })
}

# nolint start: line_length_linter
#' `box` library function import count linter
#'
#' Checks that function imports do not exceed the defined `max`.
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @param max Maximum function imports allowed between `[` and `]`. Defaults to 8.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four, five, six, seven, eight, nine])",
#'   linters = box_func_import_count_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four])",
#'   linters = box_func_import_count_linter(3)
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(package[one, two, three, four, five])",
#'   linters = box_func_import_count_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(package[one, two, three])",
#'   linters = box_func_import_count_linter(3)
#' )
#'
#' @export
# nolint end
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

# nolint start: line_length_linter
#' `box` library separate packages and module imports linter
#'
#' Checks that packages and modules are imported in separate `box::use()` statements.
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`
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
# nolint end
box_separate_calls_linter <- function() {
  xpath <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    (
      ./child::expr[child::SYMBOL] or
      ./child::expr[
        child::expr[child::SYMBOL] and child::OP-LEFT-BRACKET
      ]
    ) and
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

# nolint start: line_length_linter
#' `box` library trailing commas linter
#'
#' Checks that all `box:use` imports have a trailing comma. This applies to
#' package or module imports between `(` and `)`, and, optionally, function imports between
#' `[` and `]`. Take note that `lintr::commas_linter()` may come into play.
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @param check_functions Boolean flag to include function imports between `[` and `]`.
#' Defaults to FALSE.
#'
#' @return A custom linter function for use with `r-lib/lintr`
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(base, rlang)",
#'   linters = box_trailing_commas_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(
#'    dplyr[select, mutate]
#'   )",
#'   linters = box_trailing_commas_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(base, rlang, )",
#'   linters = box_trailing_commas_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(
#'     dplyr[select, mutate],
#'   )",
#'   linters = box_trailing_commas_linter()
#' )
#'
#' @export
# nolint end
box_trailing_commas_linter <- function(check_functions = FALSE) {
  base_xpath <- "//SYMBOL_PACKAGE[
    (
      text() = 'box' and
      following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use']
    )
  ]
  /parent::expr
  "

  right_paren_xpath <- paste(
    base_xpath,
    "/following-sibling::OP-RIGHT-PAREN[
       preceding-sibling::*[1][not(self::OP-COMMA)]
      ]
    "
  )

  right_bracket_xpath <- paste(
    base_xpath,
    "/parent::expr
      /descendant::OP-RIGHT-BRACKET[
        preceding-sibling::*[1][
          not(self::OP-COMMA) and
          not(self::expr[
            SYMBOL[text() = '...']
          ])
        ]
      ]
    "
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    bad_right_paren_expr <- xml2::xml_find_all(xml, right_paren_xpath)

    paren_lints <- lintr::xml_nodes_to_lints(
      bad_right_paren_expr,
      source_expression = source_expression,
      lint_message = "Always have a trailing comma at the end of imports, before a `)`.",
      type = "style"
    )

    bracket_lints <- NULL
    if (check_functions) {
      bad_right_bracket_expr <- xml2::xml_find_all(xml, right_bracket_xpath)

      bracket_lints <- lintr::xml_nodes_to_lints(
        bad_right_bracket_expr,
        source_expression = source_expression,
        lint_message = "Always have a trailing comma at the end of imports, before a `]`.",
        type = "style"
      )
    }

    c(paren_lints, bracket_lints)
  })
}

# nolint start: line_length_linter
#' `box` library universal import linter
#'
#' Checks that all function imports are explicit. `package[...]` is not used.
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
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
# nolint end
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
