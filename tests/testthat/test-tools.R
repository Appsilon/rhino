test_that("build_sass_r builds a minified CSS file out of a Sass file", {
  wd <- getwd()

  withr::with_tempdir({
    fs::dir_create("app", "styles")
    fs::file_copy(
      fs::path(wd, "helpers", "main.scss"),
      fs::path("app", "styles", "main.scss")
    )

    build_sass_r()

    minified_css_path <- fs::path("app", "static", "css", "app.min.css")

    expect_true(fs::file_exists(minified_css_path))

    output <- readLines(minified_css_path)[[1]]
  })

  expect_equal(
    output,
    ".components-container{display:inline-grid;grid-template-columns:1fr 1fr;width:100%}.components-container .component-box{padding:10px;margin:10px}" # nolint: line_length_linter
  )
})
