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
#' Builds the `app/js/index.js` file into `app/static/js/app.min.js`.
#' The code is transformed and bundled
#' using [Babel](https://babeljs.io) and [Webpack](https://webpack.js.org),
#' so the latest JavaScript features can be used
#' (including ECMAScript 2015 aka ES6 and newer standards).
#'
#' Functions/objects defined in the global scope do not automatically become `window` properties,
#' so the following JS code:
#' ```js
#'   function sayHello() { alert('Hello!'); }
#' ```
#' won't work as expected if used in R like this:
#' ```R
#'   tags$button("Hello!", onclick = 'sayHello()');
#' ```
#'
#' Instead you should explicitly export functions:
#' ```js
#'   export function sayHello() { alert('Hello!'); }
#' ```
#' and access them via the global `App` object:
#' ```R
#'   tags$button("Hello!", onclick = "App.sayHello()")
#' ```
#'
#' @export
build_js <- function() {
  yarn("build-js")
}

#' Lint JavaScript
#'
#' Runs [ESLint](https://eslint.org) on the JavaScript sources in the `app/js` directory.
#'
#' If your code uses global objects defined by other JS libraries or R packages,
#' you'll need to let the linter know or it will complain about undefined objects.
#' For example, the `{leaflet}` package defines a global object `L`.
#' To access it without raising linter errors, add `/* global L */` comment in your JS code.
#'
#' You don't need to define `Shiny` and `$` as these globals are defined by default.
#'
#' If you find a particular ESLint error unapplicable to your code,
#' you can disable a specific rule for the next line of code with a comment like:
#' ```js
#'   // eslint-disable-next-line no-restricted-syntax
#' ```
#' See the [ESLint documentation](https://eslint.org/docs/user-guide/configuring/rules#using-configuration-comments-1)
#' for full details.
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

#' Run Cypress end-to-end tests
#'
#' @export
test_e2e <- function() {
  yarn("test-e2e")
}
