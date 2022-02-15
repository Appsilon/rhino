test_that("rename_template_path() works", {
  path <- fs::path("dot.hidden", "app.Rproj.template")
  expected <- fs::path(".hidden", "app.Rproj")
  expect_identical(rename_template_path(path), expected)
})
