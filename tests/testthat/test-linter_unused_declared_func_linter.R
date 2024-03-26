test_that("unused_declared_func_linter skips used declared functions", {
  linter <- unused_declared_func_linter()

  good_box_usage_1 <- "sample_fun <- function(x, y) {
    x + y
  }

  sample_fun(2, 3)
  "

  good_box_usage_2 <- "assign('x', function(y) {y + 1})
  assign('y', 4)
  x(y)
  "

  good_box_usage_3 <- 'assign("x", function(y) {y + 1})
  assign("y", 4)
  x(y)
  '

  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
  lintr::expect_lint(good_box_usage_3, NULL, linter)
})

test_that("unused_declared_func_linter blocks unused declared functions", {
  linter <- unused_declared_func_linter()
  lint_message <- rex::rex("Declared function unused.")

  bad_box_usage_1 <- "sample_fun <- function(x, y) {
    x + y
  }
  "

  bad_box_usage_2 <- "assign('x', function(y) {y + 1})
  assign('y', 4)
  "

  bad_box_usage_3 <- 'assign("x", function(y) {y + 1})
  assign("y", 4)
  '

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
})
