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

test_that("with_head_tags() handles UI defined as a tag", {
  ui <- shiny::tags$div("test")
  wrapped <- with_head_tags(ui)
  expect_s3_class(wrapped, "shiny.tag.list")
})

test_that("with_head_tags() handles UI defined as a function without parameters", {
  ui <- function() shiny::tags$div("test")
  wrapped <- with_head_tags(ui)
  expect_identical(formals(wrapped), formals(ui))
})

test_that("with_head_tags() handles UI defined as a function with a request parameter", {
  ui <- function(request) shiny::tags$div("test")
  wrapped <- with_head_tags(ui)
  expect_identical(formals(wrapped), formals(ui))
})
