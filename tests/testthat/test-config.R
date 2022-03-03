test_that("validate_config() checks field value", {
  def <- list(
    list(
      name = "field",
      options = c("apples", "bananas"),
      required = FALSE
    )
  )
  expect_silent(validate_config(def, list()))
  expect_silent(validate_config(def, list(field = "apples")))
  expect_silent(validate_config(def, list(field = "bananas")))
  expect_error(validate_config(def, list(field = "cherries")))
})

test_that("validate_config() checks for required fields", {
  def <- list(
    list(
      name = "field",
      options = c("apples", "bananas"),
      required = TRUE
    )
  )
  expect_error(validate_config(def, list()))
})

test_that("validate_config() rejects unknown fields", {
  def <- list()
  expect_error(validate_config(def, list(field = "hello")))
})
