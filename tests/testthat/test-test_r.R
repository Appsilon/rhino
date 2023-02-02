test_that("test_r works with default parameters", {
  paths <- fs::dir_ls("test_recursive", glob = "*.R", recurse = TRUE, type = "file")

  expect_output(test_r(paths))
})

test_that("test_r returns an invisible data.frame with the correct number of rows", {
  paths <- fs::dir_ls("test_recursive", glob = "*.R", recurse = TRUE, type = "file")

  expect_invisible(test_results <- test_r(paths))
  expect_s3_class(test_results, "data.frame")
  expect_equal(nrow(test_results), 5)
})

test_that("test_r returns a list when raw_testthat_output = TRUE", {
  paths <- fs::dir_ls("test_recursive", glob = "*.R", recurse = TRUE, type = "file")

  test_results <- test_r(paths, raw_testthat_output = TRUE)

  expect_type(test_results, "list")
  expect_length(test_results, 3)
})

test_that("test_r shows the correct test summary", {
  paths <- fs::dir_ls("test_recursive", glob = "*.R", recurse = TRUE, type = "file")

  expect_output(test_r(paths), "[ FAIL 1 | WARN 0 | SKIP 1 | PASS 3 ]", fixed = TRUE)
})

test_that("test_r accepts a single test file", {
  path <- "test_recursive/test-main.R"

  expect_output(test_results <- test_r(path))
  expect_equal(nrow(test_results), 1)
})

test_that("test_r accepts more than one test file", {
  paths <- c("test_recursive/test-main.R", "test_recursive/logic/test-logic_sample.R")

  expect_output(test_results <- test_r(paths))
  expect_equal(nrow(test_results), 3)
})

test_that("test_r accepts a directory as path for tests", {
  path <- "test_recursive/logic/test-logic_sample.R"

  test_results <- test_r(path)

  expect_equal(nrow(test_results), 2)
})

test_that("test_r accepts more than one directory as paths for tests", {
  paths <- c(
    "test_recursive/logic/test-logic_sample.R",
    "test_recursive/view/test-view_sample.R"
  )

  test_results <- test_r(paths)

  expect_equal(nrow(test_results), 4)
})

test_that("test_r accepts a mix of files and directories as paths", {
  paths <- c(
    "test_recursive/logic/test-logic_sample.R",
    "test_recursive/view/"
  )

  test_results <- test_r(paths)

  expect_equal(nrow(test_results), 4)
})

test_that("test_r shows a failed test", {
  path <- "test_recursive/logic/test-logic_sample.R"

  expect_output(test_r(path), "Failures")
  expect_output(test_r(path), "a failed test example", ignore.case = TRUE)
})

test_that("test_r shows a failed test inline when inline_issues = TRUE", {
  path <- "test_recursive/logic/test-logic_sample.R"

  # "Failures" section should not show
  expect_output(test_r(path, inline_issues = TRUE), "(?!Failures).*$", perl = TRUE)
  expect_output(test_r(path, inline_issues = TRUE), "a failed test example", ignore.case = TRUE)
})

test_that("test_r shows a skipped test", {
  path <- "test_recursive/view/test-view_sample.R"
  
  expect_output(test_r(path), "Skipped tests")
  expect_output(test_r(path), "skip example", ignore.case = TRUE)
})

test_that("test_r shows a skipped test inline when inline_issues = TRUE", {
  path <- "test_recursive/view/test-view_sample.R"
  
  # "Failures" section should not show
  expect_output(test_r(path, inline_issues = TRUE), "(?!Skipped tests).*$", perl = TRUE)
  expect_output(test_r(path, inline_issues = TRUE), "skip example", ignore.case = TRUE)
})