test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("skip example", {
  skip("Skip this")
  expect_true(TRUE)
})

test_that("warning example", {
  warning("warn warn warn")
  expect_true(TRUE)
})
