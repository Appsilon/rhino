good_box_calls <- "box::use(
  dplyr,
  shiny,
)

box::use(
  path/to/file1,
  path/to/file2,
)"

bad_box_call_1 <- "box::use(
  dplyr,
  path/to/file,
)"

bad_box_call_2 <- "box::use(
  path/to/file,
  dplyr,
)"

lint_message <- rex::rex("Separate packages and modules in their respective box::use() calls.")

test_that("box_separate_calls_linter skips allowed box::use() calls", {
  linter <- box_separate_calls_linter()
  
  lintr::expect_lint(good_box_calls, NULL, linter)
})

test_that("box_separate_calls_linter blocks packages and modules in same box::use() call", {
  linter <- box_separate_calls_linter()
  
  lintr::expect_lint(bad_box_call_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_call_2, list(message = lint_message), linter)
})
