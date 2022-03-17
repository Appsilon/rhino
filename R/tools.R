#' Run R unit tests
#'
#' Uses the `{testhat}` package to run all unit tests in `tests/testthat` directory.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Run all unit tests in the `tests/testthat` directory.
#'   test_r()
#' }
#'
#' @export
test_r <- function() {
  testthat::test_dir(fs::path("tests", "testthat"))
}

#' Lint R
#'
#' Uses the `{lintr}` package to check all R sources in the `app` and `tests/testthat` directories
#' for style errors.
#'
#' The linter rules can be adjusted in the `.lintr` file.
#'
#' @param accepted_errors Number of accepted style errors.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Lint all R sources in the `app` and `tests/testthat` directories.
#'   lint_r()
#'
#'   # Accept up to 10 errors:
#'   lint_r(accepted_errors = 10)
#' }
#'
#' @export
lint_r <- function(accepted_errors = 0) {
  lints <- c(
    lintr::lint_dir("app"),
    lintr::lint_dir(fs::path("tests", "testthat"))
  )

  style_errors <- length(lints)

  if (style_errors > accepted_errors) {
    print(lints)
    cli::cli_abort("Number of style errors: {style_errors}.")
  }
}

rhino_style <- function() {
  style <- styler::tidyverse_style()
  style$space$style_space_around_math_token <- NULL
  style
}

#' Format R
#'
#' Uses the `{styler}` package to automatically format R sources.
#'
#' The code is formatted according to the `styler::tidyverse_style` guide with one adjustment:
#' spacing around math operators is not modified to avoid conflicts with `box::use()` statements.
#'
#' @param paths Character vector of files and directories to format.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Format a single file.
#'   format_r("app/main.R")
#'
#'   # Format all files in a directory.
#'   format_r("app/view")
#' }
#'
#' @export
format_r <- function(paths) {
  for (path in paths) {
    if (fs::is_dir(path)) {
      styler::style_dir(path, style = rhino_style)
    } else {
      styler::style_file(path, style = rhino_style)
    }
  }
}

#' Build JavaScript
#'
#' Builds the `app/js/index.js` file into `app/static/js/app.min.js`.
#' The code is transformed and bundled
#' using [Babel](https://babeljs.io) and [webpack](https://webpack.js.org),
#' so the latest JavaScript features can be used
#' (including ECMAScript 2015 aka ES6 and newer standards).
#' Requires Node.js and the `yarn` command to be available on the system.
#'
#' Functions/objects defined in the global scope do not automatically become `window` properties,
#' so the following JS code:
#' ```js
#' function sayHello() { alert('Hello!'); }
#' ```
#' won't work as expected if used in R like this:
#' ```r
#' tags$button("Hello!", onclick = 'sayHello()');
#' ```
#'
#' Instead you should explicitly export functions:
#' ```js
#' export function sayHello() { alert('Hello!'); }
#' ```
#' and access them via the global `App` object:
#' ```r
#' tags$button("Hello!", onclick = "App.sayHello()")
#' ```
#'
#' @param watch Keep the process running and rebuilding JS whenever source files change.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Build the `app/js/index.js` file into `app/static/js/app.min.js`.
#'   build_js()
#' }
#'
#' @export
build_js <- function(watch = FALSE) {
  if (watch) yarn("build-js", "--watch", status_ok = 2)
  else yarn("build-js")
}

# nolint start
#' Lint JavaScript
#'
#' Runs [ESLint](https://eslint.org) on the JavaScript sources in the `app/js` directory.
#' Requires Node.js and the `yarn` command to be available on the system.
#'
#' If your JS code uses global objects defined by other JS libraries or R packages,
#' you'll need to let the linter know or it will complain about undefined objects.
#' For example, the `{leaflet}` package defines a global object `L`.
#' To access it without raising linter errors, add `/* global L */` comment in your JS code.
#'
#' You don't need to define `Shiny` and `$` as these global variables are defined by default.
#'
#' If you find a particular ESLint error inapplicable to your code,
#' you can disable a specific rule for the next line of code with a comment like:
#' ```js
#' // eslint-disable-next-line no-restricted-syntax
#' ```
#' See the [ESLint documentation](https://eslint.org/docs/user-guide/configuring/rules#using-configuration-comments-1)
#' for full details.
#'
#' @param fix Automatically fix problems.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Lint the JavaScript sources in the `app/js` directory.
#'   lint_js()
#' }
#'
#' @export
# nolint end
lint_js <- function(fix = FALSE) {
  yarn("lint-js", if (fix) "--fix")
}

#' Build Sass
#'
#' Builds the `app/styles/main.scss` file into `app/static/css/app.min.css`.
#'
#' The build method can be configured using the `sass` option in `rhino.yml`:
#' 1. `node`: Use [Dart Sass](https://sass-lang.com/dart-sass)
#' (requires Node.js and the `yarn` command to be available on the system).
#' 2. `r`: Use the `{sass}` R package.
#'
#' It is recommended to use Dart Sass which is the primary,
#' actively developed implementation of Sass.
#' On systems without `yarn` you can use the `{sass}` R package as a fallback.
#' It is not advised however, as it uses the deprecated
#' [LibSass](https://sass-lang.com/blog/libsass-is-deprecated) implementation.
#'
#' @param watch Keep the process running and rebuilding Sass whenever source files change.
#' Only supported for `sass: node` configuration in `rhino.yml`.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Build the `app/styles/main.scss` file into `app/static/css/app.min.css`.
#'   build_sass()
#' }
#'
#' @export
build_sass <- function(watch = FALSE) {
  config <- read_config()$sass
  if (config == "node") {
    if (watch) yarn("build-sass", "--watch", status_ok = 2)
    else yarn("build-sass")
  } else if (config == "r") {
    if (watch) {
      cli::cli_alert_warning("The {.arg watch} argument is only supported when using Node.")
    }
    output_dir <- fs::path("app", "static", "css")
    fs::dir_create(output_dir)
    sass::sass(
      input = sass::sass_file(fs::path("app", "styles", "main.scss")),
      output = fs::path(output_dir, "app.min.css"),
      cache = FALSE
    )
  }
}

#' Lint Sass
#'
#' Runs [Stylelint](https://stylelint.io/) on the Sass sources in the `app/styles` directory.
#' Requires Node.js and the `yarn` command to be available on the system.
#'
#' @param fix Automatically fix problems.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Lint the Sass sources in the `app/styles` directory.
#'   lint_sass()
#' }
#'
#' @export
lint_sass <- function(fix = FALSE) {
  yarn("lint-sass", if (fix) "--fix")
}

#' Run Cypress end-to-end tests
#'
#' Uses [Cypress](https://www.cypress.io/) to run end-to-end tests
#' defined in the `tests/cypress` directory.
#' Requires Node.js and the `yarn` command to be available on the system.
#'
#' @param interactive Should Cypress be run in the interactive mode?
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Run the end-to-end tests in the `tests/cypress` directory.
#'   test_e2e()
#' }
#'
#' @export
test_e2e <- function(interactive = FALSE) {
  command <- ifelse(isTRUE(interactive), "test-e2e-interactive", "test-e2e")

  yarn(command)
}
