test_that("box_trailing_commas_linter skips allowed package import usage", {
  linter <- box_trailing_commas_linter()

  good_package_commas <- "box::use(
    dplyr,
    stringr[
      select,
      mutate
    ],
  )"

  good_package_commas_inline <- "box::use(dplyr, stringr[select, mutate], )"

  good_module_commas <- "box::use(
    path/to/file1,
    path/to/file2[
      first_function,
      second_function
    ],
  )"

  good_module_commas_inline <- "box::use(path/to/file1, path/to/file2, )"

  lintr::expect_lint(good_package_commas, NULL, linter)
  lintr::expect_lint(good_package_commas_inline, NULL, linter)
  lintr::expect_lint(good_module_commas, NULL, linter)
  lintr::expect_lint(good_module_commas_inline, NULL, linter)
})

test_that("box_trailing_commas_linter blocks no trailing commas in package imports", {
  linter <- box_trailing_commas_linter()

  bad_package_commas <- "box::use(
    dplyr,
    stringr
  )"

  bad_package_commas_inline <- "box::use(dplyr, stringr)"

  paren_lint_msg <- rex::rex("Always have a trailing comma at the end of imports, before a `)`.")

  lintr::expect_lint(bad_package_commas, list(message = paren_lint_msg), linter)
  lintr::expect_lint(bad_package_commas_inline, list(message = paren_lint_msg), linter)
})

test_that("box_trailing_commas_linter check_functions = TRUE blocks no trailing commas", {
  linter <- box_trailing_commas_linter(check_functions = TRUE)

  bracket_lint_msg <- rex::rex("Always have a trailing comma at the end of imports, before a `]`.")

  bad_package_function_commas <- "box::use(
    dplyr,
    stringr[
      select,
      mutate
    ],
  )"

  bad_pkg_function_commas_inline <- "box::use(stringr[select, mutate],)"

  lintr::expect_lint(bad_package_function_commas, list(message = bracket_lint_msg), linter)
  lintr::expect_lint(bad_pkg_function_commas_inline, list(message = bracket_lint_msg), linter)
})

test_that("box_trailing_comma_linter blocks no trailing commas in module imports", {
  linter <- box_trailing_commas_linter()

  bad_module_commas <- "box::use(
    path/to/file1,
    path/to/file2
  )"

  bad_module_commas_inline <- "box::use(path/to/file1, path/to/file2)"

  paren_lint_msg <- rex::rex("Always have a trailing comma at the end of imports, before a `)`.")

  lintr::expect_lint(bad_module_commas, list(message = paren_lint_msg), linter)
  lintr::expect_lint(bad_module_commas_inline, list(message = paren_lint_msg), linter)
})

test_that("box_trailing_commas_linter check_functions = TRUE blocks no trailing commas", {
  linter <- box_trailing_commas_linter(check_functions = TRUE)

  bad_module_function_commas <- "box::use(
    path/to/file2[
      first_function,
      second_function
    ],
  )"

  bad_mod_function_commas_inline <- "box::use(path/to/file2[first_function, second_function], )"

  bracket_lint_msg <- rex::rex("Always have a trailing comma at the end of imports, before a `]`.")

  lintr::expect_lint(bad_module_function_commas, list(message = bracket_lint_msg), linter)
  lintr::expect_lint(bad_mod_function_commas_inline, list(message = bracket_lint_msg), linter)
})

test_that("box_trailing_commas_linter should not lint outside of `box::use()`", {
  linter <- box_trailing_commas_linter()

  should_not_lint <- "x <- c(1, 2, 3)"

  lintr::expect_lint(should_not_lint, NULL, linter)
})
