test_that("init() builds in the home directory", {
  expect_message(init("~"))
})
