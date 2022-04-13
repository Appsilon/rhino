test_that("validate_config() checks option fields", {
  def <- list(
    list(
      name = "field",
      validator = option_validator("apples", "bananas"),
      required = FALSE
    )
  )
  expect_silent(validate_config(def, list()))
  expect_silent(validate_config(def, list(field = "apples")))
  expect_silent(validate_config(def, list(field = "bananas")))
  expect_error(validate_config(def, list(field = "cherries")))
})

test_that("validate_config() checks integer fields", {
  def <- list(
    list(
      name = "field",
      validator = positive_integer_validator,
      required = FALSE
    )
  )
  expect_silent(validate_config(def, list()))
  expect_silent(validate_config(def, list(field = 1L)))
  expect_error(validate_config(def, list(field = 1.)))
  expect_error(validate_config(def, list(field = "1")))
})

test_that("validate_config() checks for required fields", {
  def <- list(
    list(
      name = "field",
      options = positive_integer_validator,
      required = TRUE
    )
  )
  expect_error(validate_config(def, list()))
})

test_that("validate_config() rejects unknown fields", {
  def <- list()
  expect_error(validate_config(def, list(field = "hello")))
})
