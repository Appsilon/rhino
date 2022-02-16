#' Run unit tests
#'
#' @importFrom fs path
#' @export
test_r <- function() {
  testthat::test_dir(path("tests", "testthat"))
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

#' Run linter for Sass
#'
#' @export
lint_sass <- function() {
  yarn("lint-sass")
}
