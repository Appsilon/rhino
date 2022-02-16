test_that("rename_template_path() works", {
  path <- fs::path("dot.hidden", "app.Rproj.template")
  expected <- fs::path(".hidden", "app.Rproj")
  expect_identical(rename_template_path(path), expected)
})

test_that("rename_template_path() is not too eager", {
  path1 <- fs::path("dots")
  path2 <- fs::path("atemplate")
  expect_identical(rename_template_path(path1), path1)
  expect_identical(rename_template_path(path2), path2)
})
