test_that("check_if_includes_r_files finds R and r files", {
  withr::with_tempdir({
    for (extension in c("R", "r")) {
      path <- fs::path("app", extension)
      fs::dir_create(path)
      fs::file_create(fs::path(path, paste0("module.", extension)))
      expect_equal(check_if_includes_r_files(path), normalizePath(path))
    }

    fs::dir_create("app/no_r")
    fs::file_create("app/no_r/readme.txt")
    expect_null(check_if_includes_r_files("app/no_r"))
  })
})

test_that("starts_with is able to detect paths that start with a given prefix", {
  expect_true(starts_with("app/logic/utils.R", "app/logic"))
  expect_true(starts_with("app/main.R", "app"))
  expect_false(starts_with("app/view/module.R", "app/logic"))
})

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

test_that("covr_r runs a coverage test on a rhino app.", {
  skip_on_covr()
  wd <- getwd()

  withr::with_tempdir({
    fs::dir_create("app")
    fs::dir_create("app", "logic")
    fs::dir_create("tests", "testthat")

    fs::file_copy(
      fs::path(wd, "helpers", "main.R"),
      fs::path("app", "main.R")
    )

    fs::file_copy(
      fs::path(wd, "helpers", "hello.R"),
      fs::path("app", "logic", "hello.R")
    )

    fs::file_copy(
      fs::path(wd, "helpers", "say_hello_module.R"),
      fs::path("app", "logic", "say_hello_module.R")
    )

    fs::file_copy(
      fs::path(wd, "helpers", "test-hello.R"),
      fs::path("tests", "testthat", "test-hello.R")
    )

    fs::file_copy(
      fs::path(wd, "helpers", "test-say_hello_module.R"),
      fs::path("tests", "testthat", "test-say_hello_module.R")
    )

    box::purge_cache()
    configure_box()

    expect_no_error(covr_r())
    expect_no_error(covr_report())
  })
})
