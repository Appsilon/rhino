test_that("init() builds in the home directory", {
  expect_message(init("~"), "Refusing to create rhino in")
})

test_that("init() builds in a directory with rhino app structure", {
  dir_path <- test_path("dummy_app_dir")

  expect_message(init(dir_path), "app structure already exists")
})
