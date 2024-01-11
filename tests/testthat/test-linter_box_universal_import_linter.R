good_package_imports <- "box::use(
    dplyr[select, mutate, ],
    stringr[str_sub, str_match, ],
  )
"

good_module_imports <- "box::use(
    path/to/file1[do_something, do_another, ],
    path/to/file2[find_x, find_y, ],
  )
"

bad_package_imports <- "box::use(
    dplyr[...],
    stringr[str_sub, str_match, ],
  )
"

bad_module_imports <- "box::use(
    path/to/file1[...],
    path/to/file2[find_x, find_y, ],
  )
"

function_with_three_dots <- "some_function <- function(...) {
    sum(...)
  }
"

no_lint <- "box::use(
    shiny[...],         # nolint
  )
"

lint_msg <- rex::rex("Explicitly declare imports rather than universally import with `...`.")

test_that("box_universal_count_linter skips allowed package import usage", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(good_package_imports, NULL, linter)
})

test_that("box_universal_count_linter skips allowed module import usage", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(good_module_imports, NULL, linter)
})

test_that("box_universal_count_linter blocks disallowed package import usage", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(bad_package_imports, list(message = lint_msg), linter)
})

test_that("box_universal_count_linter blocks disallowed module import usage", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(bad_module_imports, list(message = lint_msg), linter)
})

test_that("box_universal_count_linter skips three dots in function declarations and calls", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(function_with_three_dots, NULL, linter)
})

test_that("box_universal_count_linter respects #nolint", {
  linter <- box_universal_import_linter()

  lintr::expect_lint(no_lint, NULL, linter)
})
