#' Run R unit tests
#'
#' @importFrom fs path
#' @export
test_r <- function() {
  testthat::test_dir(path("tests", "testthat"))
}

#' Lint R
#'
#' @param accepted_errors Number of accepted style errors.
#'
#' @export
lint_r <- function(accepted_errors = 0) {
  lints <- c(
    lintr::lint("app.R"),
    lintr::lint_dir("app"),
    lintr::lint_dir(path("tests", "testthat"))
  )

  style_errors <- length(lints)

  if (style_errors > accepted_errors) {
    print(lints)
    stop(sprintf("Number of style errors: %s", style_errors))
  }
}

#' Format R
#'
#' @param path File or directory to format
#'
#' @export
format_r <- function(path) {
  if (fs::is_dir(path)) {
    styler::style_dir(path)
  } else {
    styler::style_file(path)
  }
}

#' Build JavaScript
#'
#' @export
build_js <- function() {
  yarn("build-js")
}

#' Lint JavaScript
#'
#' @export
lint_js <- function() {
  yarn("lint-js")
}

#' Build Sass
#'
#' @importFrom fs dir_create path
#' @export
build_sass <- function() {
  config <- read_config()$sass
  if (config == "node") {
    yarn("build-sass")
  } else if (config == "r") {
    output_dir <- path("app", "static", "css")
    dir_create(output_dir)
    sass::sass(
      input = sass::sass_file(path("app", "styles", "main.scss")),
      output = path(output_dir, "app.min.css"),
      cache = FALSE
    )
  }
}

#' Lint Sass
#'
#' @export
lint_sass <- function() {
  yarn("lint-sass")
}
