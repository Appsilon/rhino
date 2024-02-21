test_that("box_separate_calls_linter skips allowed box::use() calls", {
  linter <- box_separate_calls_linter()

  good_box_calls_1 <- "box::use(
    dplyr,
    shiny,
  )

  box::use(
    path/to/file1,
    path/to/file2,
  )"

  good_box_calls_2 <- "box::use(
    dplyr[filter, select],
    shiny,
  )

  box::use(
    path/to/file1[function1, function2],
    path/to/file2,
  )"

  lintr::expect_lint(good_box_calls_1, NULL, linter)
  lintr::expect_lint(good_box_calls_2, NULL, linter)
})

test_that("box_separate_calls_linter blocks packages and modules in same box::use() call", {
  linter <- box_separate_calls_linter()

  bad_box_call_1 <- "box::use(
    dplyr,
    path/to/file,
  )"

  bad_box_call_2 <- "box::use(
    path/to/file,
    dplyr,
  )"

  bad_box_call_3 <- "box::use(
    path/to/file,
    dplyr[filter, select],
  )"

  bad_box_call_4 <- "box::use(
    path/to/file[function1, function2],
    dplyr,
  )"

  bad_box_call_5 <- "box::use(
    path/to/file[function1, function2],
    dplyr[filter, select],
  )"

  bad_box_call_6 <- "box::use(
    a = path/to/file,
    dplyr,
  )"

  bad_box_call_7 <- "box::use(
    path/to/file,
    a = dplyr,
  )"

  bad_box_call_8 <- "box::use(
    path/to/file,
    dplyr[a = filter, select],
  )"

  bad_box_call_9 <- "box::use(
    path/to/file[a = function1, function2],
    dplyr,
  )"

  lint_message <- rex::rex("Separate packages and modules in their respective box::use() calls.")

  lintr::expect_lint(bad_box_call_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_3, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_4, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_5, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_6, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_7, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_8, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_9, list(message = lint_message), linter)
})
