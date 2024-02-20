lint_message <- function(max = 5L) {
  rex::rex(glue::glue("Limit the function imports to a max of {max}."))
}

test_that("box_func_import_count_linter skips allowed function count.", {
  linter <- box_func_import_count_linter(max = 5)

  five_function_imports <- "box::use(
    dplyr[
      arrange,
      select,
      mutate,
      distinct,
      filter,
    ],
  )"

  five_function_imports_inline <- "box::use(
    dplyr[arrange, select, mutate, distinct, filter, ],
  )"

  lintr::expect_lint(five_function_imports, NULL, linter)
  lintr::expect_lint(five_function_imports_inline, NULL, linter)
})

test_that("box_func_import_count_linter skips allowed function count supplied max", {
  linter <- box_func_import_count_linter(max = 3)

  three_function_imports <- "box::use(
    dplyr[
      arrange,
      select,
      mutate,
    ],
  )"

  three_function_imports_inline <- "box::use(
    dplyr[arrange, select, mutate, ],
  )"

  lintr::expect_lint(three_function_imports, NULL, linter)
  lintr::expect_lint(three_function_imports_inline, NULL, linter)
})

test_that("box_func_import_count_linter blocks function imports more than max", {
  max <- 5
  linter <- box_func_import_count_linter(max = max)
  lint_msg <- lint_message(max)

  six_function_imports <- "box::use(
    dplyr[
      arrange,
      select,
      mutate,
      distinct,
      filter,
      slice,
    ],
  )"

  six_function_imports_inline <- "box::use(
    dplyr[arrange, select, mutate, distinct, filter, slice, ],
  )"

  lintr::expect_lint(six_function_imports, list(message = lint_msg), linter)
  lintr::expect_lint(six_function_imports_inline, list(message = lint_msg), linter)
})

test_that("box_func_import_count_linter resepect # nolint", {
  linter <- box_func_import_count_linter()

  no_lint <- "box::use(
    dplyr[        # nolint
      arrange,
      select,
      mutate,
      distinct  
    ],  
  )"

  no_lint_inline <- "box::use(
    dplyr[arrange, select, mutate, distinct], # nolint
  )"

  lintr::expect_lint(no_lint, NULL, linter)
  lintr::expect_lint(no_lint_inline, NULL, linter)
})
