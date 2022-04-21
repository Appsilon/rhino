test_that("configure_logger() works with missing config fields", {
  mockery::stub(configure_logger, "config::get", list())
  expect_message(configure_logger())

  mockery::stub(configure_logger, "config::get", list(rhino_log_level = "INFO"))
  expect_message(configure_logger())

  mockery::stub(configure_logger, "config::get", list(rhino_log_file = "my.log"))
  expect_message(configure_logger())

  mockery::stub(
    configure_logger,
    "config::get",
    list(rhino_log_level = "INFO", rhino_log_file = "my.log")
  )
  expect_silent(configure_logger())
})
