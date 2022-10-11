test_that("lint_r does not throw lint errors or success messages", {
  app_path <- test_path("dir_with_lint_errors")

  mockery::stub(lint_r, "read_config", list())

  expect_error(lint_r(app_path))
  expect_error(lint_r(fs::path(app_path, "dir_with_lint_errors")))
  expect_error(lint_r(fs::path(app_path, "bad.R")))
  expect_error(lint_r(fs::path(app_path, c("bad.R", "bad2.R"))))
  expect_error(lint_r(fs::path(app_path, c("dir_with_lint_errors", "bad.R", "bad2.R"))))
  expect_message(
    lint_r(fs::path(app_path, "dir_with_lint_errors", "good.R")),
    "No style errors found."
  )
  expect_message(
    lint_r(
      c(
        fs::path(app_path, "dir_with_lint_errors", "good.R"),
        fs::path(app_path, "good.R")
      )
    ),
    "No style errors found."
  )
})
