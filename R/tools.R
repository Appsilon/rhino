#' Run R unit tests
#'
#' Uses the `{testhat}` package to run all unit tests in `tests/testthat` directory.
#'
#' @param ... Additional arguments passed to `testthat::test_dir()`.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Run all unit tests in the `tests/testthat` directory.
#'   test_r()
#' }
#' @export
test_r <- function(...) {
  box::purge_cache()
  testthat::test_dir(
    path = fs::path("tests", "testthat"),
    ...
  )
}

# From testthat https://github.com/r-lib/testthat/blob/v3.2.3/R/auto-test.R#L130
starts_with <- function(string, prefix) {
  substr(string, 1, nchar(prefix)) == prefix
}

check_if_includes_r_files <- function(path) {
  r_files <- fs::dir_ls(path, recurse = TRUE, regexp = "*.[Rr]$")

  if (length(r_files) > 0) {
    return(normalizePath(path))
  }

  NULL
}

formatted_time <- function() {
  format(as.POSIXct(Sys.time()), "%F %T")
}

# nolint start: line_length_linter
#' Watch and automatically run R tests
#'
#' Watches R files in the `app` directory and `tests/testthat` directory for changes.
#' When code files in `app` change, all tests are rerun. When test files change,
#' only the changed test file is rerun.
#'
#' @param reporter `{testthat}` reporter to use.
#'   If NULL, will use `testthat::default_reporter()` for tests when running all tests
#'   and `testthat::default_compact_reporter()` for single file tests.
#'   See [`{testthat}` reporters](https://testthat.r-lib.org/reference/Reporter.html) for more details.
#' @param filter filter passed to `testthat::test_dir()`. If not NULL, only tests with file names matching this regular expression will be executed.
#'   Matching is performed on the file name after it's stripped of "test-" and ".R".
#'   Does not affect the case when a test file is changed. In this case, this test file is rerun.
#' @param hash Logical. Whether to use file hashing to detect changes. Default is TRUE.
#'   If FALSE, file modification times are used instead.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Watch files and automatically run tests when changes are detected
#'   auto_test_r()
#' }
#' @export
# nolint end
auto_test_r <- function(reporter = NULL, filter = NULL, hash = TRUE) {
  test_path <- normalizePath(fs::path("tests", "testthat"))

  code_path <- c(
    normalizePath("app"),
    unlist(fs::dir_map("app", check_if_includes_r_files, recurse = TRUE, type = "directory"))
  )

  if (is.null(reporter)) {
    single_file_reporter <- testthat::default_compact_reporter()
  } else {
    single_file_reporter <- reporter
  }

  test_r(reporter = reporter, filter = filter, stop_on_failure = FALSE)

  watcher <- function(added, deleted, modified) {
    changed <- normalizePath(c(added, modified))

    tests <- changed[starts_with(changed, test_path)]

    code <- changed[starts_with(changed, code_path)]

    if (length(code) > 0) {
      # Reload code and rerun all tests
      cli::cli_alert_info(
        "[{formatted_time()}] Changed code: {paste0(basename(code), collapse = ', ')}"
      )
      cli::cli_alert_info("[{formatted_time()}] Rerunning all tests")
      test_r(reporter = reporter, filter = filter, stop_on_failure = FALSE)
    } else if (length(tests) > 0) {
      # If test changes, rerun just that test
      box::purge_cache()
      cli::cli_alert_info(
        "[{formatted_time()}] Rerunning tests: {paste0(basename(tests), collapse = ', ')}"
      )
      testthat::test_file(tests, reporter = single_file_reporter, stop_on_failure = FALSE)
    }

    TRUE
  }
  testthat::watch(c(code_path, test_path), watcher, hash = hash)
}

lint_dir <- function(path) {
  if (interactive()) {
    message(cli::format_inline("Linting {.file {path}}"), appendLF = FALSE)
  }
  lints <- lintr::lint_dir(path)
  # Return lints with full relative paths, e.g. `app/main.R` instead of just `main.R`.
  for (i in seq_along(lints)) {
    lints[[i]]$filename <- fs::path(path, lints[[i]]$filename)
  }
  lints
}

lint_file <- function(path) {
  if (interactive()) {
    message(cli::format_inline("Linting {.file {path}}"))
  }
  lints <- lintr::lint(path)
  # Use the actual path provided by the user (typically relative) to make results more readable.
  # (`lintr::lint()` normalizes paths, e.g. `app/main.R` becomes a full absolute path.)
  for (i in seq_along(lints)) {
    lints[[i]]$filename <- path
  }
  lints
}

lint_path <- function(path) {
  # Check if path is a directory or a file such that nothing happens when the path is invalid.
  if (fs::is_dir(path)) {
    lint_dir(path)
  } else if (fs::is_file(path)) {
    lint_file(path)
  } else {
    cli::cli_abort("Unexpected invalid path: {.file {path}}.")
  }
}

check_paths <- function(paths) {
  readable <- fs::file_access(paths, mode = "read")

  if (any(!readable)) {
    cli::cli_abort(
      c(
        "Cannot lint an invalid path.",
        i = "Please check that {.arg paths} contain only valid paths.",
        i = "The following path{?s} cannot be read: {.file {paths[!readable]}}."
      ),
      call = NULL
    )
  }
}

# nolint start: line_length_linter
#' Lint R
#'
#' Uses the `{lintr}` package to check all R sources in the `app` and `tests/testthat` directories
#' for style errors.
#'
#' The linter rules can be [adjusted](https://lintr.r-lib.org/articles/lintr.html#configuring-linters)
#' in the `.lintr` file.
#'
#' You can set the maximum number of accepted style errors
#' with the `legacy_max_lint_r_errors` option in `rhino.yml`.
#' This can be useful when inheriting legacy code with multiple styling issues.
#'
#' The [box.linters::namespaced_function_calls()] linter requires the `{treesitter}` and
#' `{treesitter.r}` packages. These require R >= 4.3.0. `lint_r()` will continue to run and skip
#' `namespaced_function_calls()` if its dependencies are not available.
#'
#' @param paths Character vector of directories and files to lint.
#' When `NULL` (the default), check `app` and `tests/testthat` directories.
#'
#' @return None. This function is called for side effects.
#'
#' @export
# nolint end
lint_r <- function(paths = NULL) {
  if (!box.linters::is_treesitter_installed()) {
    cli::cli_warn(
      c(
        "!" = paste(
          "`box.linters::namespaced_function_calls()` requires {{treesitter}} and {{treesitter.r}}",
          "to be installed."
        ),
        "i" = "`lintr_r()` will continue to run using the other linter functions."
      )
    )
  }
  if (is.null(paths)) {
    paths <- c("app", "tests/testthat")
  }
  check_paths(paths)
  max_errors <- read_config()$legacy_max_lint_r_errors
  if (is.null(max_errors)) max_errors <- 0

  lints <- do.call(c, lapply(paths, lint_path))

  # Applying `c()` removes the `lints` class which is responsible for pretty-printing.
  class(lints) <- "lints"

  errors <- length(lints)
  if (errors == 0) {
    cli::cli_alert_success("No style errors found.")
  } else {
    print(lints)
    message <- c(
      "Found {errors} style error{?s}.",
      i = if (max_errors > 0) "At most {max_errors} error{?s} allowed."
    )
    if (errors <= max_errors) {
      cli::cli_inform(message)
    } else {
      cli::cli_abort(message, call = NULL)
    }
  }
}

rhino_style <- function() {
  styler::tidyverse_style(math_token_spacing = styler::specify_math_token_spacing(zero = "'/'"))
}

#' Format R
#'
#' Uses the `{styler}` and `{box.linters}` packages to automatically format R sources. As with
#' `styler`, carefully examine the results after running this function.
#'
#' The code is formatted according to the `styler::tidyverse_style` guide with one adjustment:
#' spacing around math operators is not modified to avoid conflicts with `box::use()` statements.
#'
#' If available, `box::use()` calls are reformatted by styling functions provided by
#' `{box.linters}`. These include:
#'
#' * Separating `box::use()` calls for packages and local modules
#' * Alphabetically sorting packages, modules, and functions.
#' * Adding trailing commas
#'
#' `box.linters::style_*` functions require the `treesitter` and `treesitter.r` packages. These, in
#' turn, require R >= 4.3.0. `format_r()` will continue to operate without these but will not
#' perform `box::use()` call styling.
#'
#' For more information on `box::use()` call styling please refer to the `{box.linters}` styling
#' functions
#' [documentation](https://appsilon.github.io/box.linters/reference/style_box_use_text.html).
#'
#' @param paths Character vector of files and directories to format.
#' @param exclude_files Character vector with regular expressions of files that should be excluded
#' from styling.
#' @param ... Optional arguments to pass to `box.linters::style_*` functions.
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
#' @export
format_r <- function(paths, exclude_files = NULL, ...) {
  style_box_use_dir <- box.linters::style_box_use_dir
  style_box_use_file <- box.linters::style_box_use_file
  if (!box.linters::is_treesitter_installed()) {
    style_box_use_dir <- function(path, exclude_files, ...) { }
    style_box_use_file <- function(path, ...) { }
    cli::cli_warn(
      c(
        "x" = "The packages {{treesitter}} and {{treesitter.r}} are required by `box::use()` styling features of `format_r()`.", #nolint
        "i" = "These package require R version >= 4.3.0 to install."
      )
    )
  }

  for (path in paths) {
    if (fs::is_dir(path)) {
      style_box_use_dir(path, exclude_files = exclude_files, ...)
      styler::style_dir(path, style = rhino_style, exclude_files = exclude_files)
    } else {
      style_box_use_file(path, ...)
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
#' Requires Node.js to be available on the system.
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
#' @export
build_js <- function(watch = FALSE) {
  if (watch) {
    npm("run", "build-js", "--", "--watch", status_ok = 2)
  } else {
    npm("run", "build-js")
  }
}

# nolint start: line_length_linter
#' Lint JavaScript
#'
#' Runs [ESLint](https://eslint.org) on the JavaScript sources in the `app/js` directory.
#' Requires Node.js to be available on the system.
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
#' @export
# nolint end
lint_js <- function(fix = FALSE) {
  if (fix) {
    npm("run", "lint-js", "--", "--fix")
  } else {
    npm("run", "lint-js")
  }
}

#' Format JavaScript
#'
#' Runs [prettier](https://prettier.io/) on JavaScript files in `app/js` directory.
#' Requires Node.js installed.
#'
#' You can prevent prettier from formatting a given chunk of your code by adding a special comment:
#' ```js
#' // prettier-ignore
#' ```
#' Read more about [ignoring code](https://prettier.io/docs/en/ignore).
#'
#' @param fix If `TRUE`, fixes formatting. If FALSE, reports formatting errors without fixing them.
#' @return None. This function is called for side effects.
#'
#' @export
format_js <- function(fix = TRUE) {
  if (fix) {
    npm("run", "format-js", "--", "--write")
  } else {
    npm("run", "format-js", "--", "--check")
  }
}

#' Build Sass
#'
#' Builds the `app/styles/main.scss` file into `app/static/css/app.min.css`.
#'
#' The build method can be configured using the `sass` option in `rhino.yml`:
#' 1. `node`: Use [Dart Sass](https://sass-lang.com/dart-sass)
#' (requires Node.js to be available on the system).
#' 2. `r`: Use the `{sass}` R package.
#'
#' It is recommended to use Dart Sass which is the primary,
#' actively developed implementation of Sass.
#' On systems without Node.js you can use the `{sass}` R package as a fallback.
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
#' @export
build_sass <- function(watch = FALSE) {
  config <- read_config()$sass
  if (config == "custom") {
    cli::cli_alert_warning(
      "Using 'custom' configuration for 'sass'. Exiting without doing anything."
    )
    return(invisible())
  }

  if (config == "node") {
    tryCatch(
      build_sass_node(watch = watch),
      error = function(error) {
        cli::cli_abort(c(
          error$message, error$body,
          i = "If you can't use Node.js, try using sass: 'r' configuration."
        ))
      }
    )
  } else if (config == "r") {
    if (watch) {
      cli::cli_alert_warning("The {.arg watch} argument is only supported when using Node.")
    }
    build_sass_r()
  }
}

build_sass_node <- function(watch = FALSE) {
  if (watch) {
    npm("run", "build-sass", "--", "--watch", status_ok = 2)
  } else {
    npm("run", "build-sass")
  }
}

build_sass_r <- function() {
  output_dir <- fs::path("app", "static", "css")
  fs::dir_create(output_dir)
  sass::sass(
    input = sass::sass_file(fs::path("app", "styles", "main.scss")),
    output = fs::path(output_dir, "app.min.css"),
    cache = FALSE,
    options = sass::sass_options(output_style = "compressed")
  )
}

#' Lint Sass
#'
#' Runs [Stylelint](https://stylelint.io/) on the Sass sources in the `app/styles` directory.
#' Requires Node.js to be available on the system.
#'
#' @param fix Automatically fix problems.
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Lint the Sass sources in the `app/styles` directory.
#'   lint_sass()
#' }
#' @export
lint_sass <- function(fix = FALSE) {
  if (fix) {
    npm("run", "lint-sass", "--", "--fix")
  } else {
    npm("run", "lint-sass")
  }
}

#' Format Sass
#'
#' Runs [prettier](https://prettier.io/) on Sass (.scss) files in `app/styles` directory.
#' Requires Node.js installed.
#'
#' You can prevent prettier from formatting a given chunk of your code by adding a special comment:
#' ```scss
#' // prettier-ignore
#' ```
#' Read more about [ignoring code](https://prettier.io/docs/en/ignore).
#'
#' @param fix If `TRUE`, fixes formatting. If FALSE, reports formatting errors without fixing them.
#' @return None. This function is called for side effects.
#'
#' @export
format_sass <- function(fix = TRUE) {
  if (fix) {
    npm("run", "format-sass", "--", "--write")
  } else {
    npm("run", "format-sass", "--", "--check")
  }
}

#' Run Cypress end-to-end tests
#'
#' Uses [Cypress](https://www.cypress.io/) to run end-to-end tests
#' defined in the `tests/cypress` directory.
#' Requires Node.js to be available on the system.
#'
#' Check out:
# nolint start: line_length_linter
#' [Tutorial: Write end-to-end tests with Cypress](https://appsilon.github.io/rhino/articles/tutorial/write-end-to-end-tests-with-cypress.html)
# nolint end
#' to learn how to write end-to-end tests for your Rhino app.
#'
#' If you want to write end-to-end tests with `{shinytest2}`, see our
#' [How-to: Use shinytest2](https://appsilon.github.io/rhino/articles/how-to/use-shinytest2.html)
#' guide.
#'
#' @param interactive Should Cypress be run in the interactive mode?
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Run the end-to-end tests in the `tests/cypress` directory.
#'   test_e2e()
#' }
#' @export
test_e2e <- function(interactive = FALSE) {
  if (interactive) {
    npm("run", "test-e2e-interactive")
  } else {
    npm("run", "test-e2e")
  }
}

#' Development mode
#'
#' Run application in development mode with automatic rebuilding and reloading.
#'
#' This function will launch the Shiny app in
#' [development mode](https://shiny.posit.co/r/reference/shiny/latest/devmode.html)
#' (as if `options(shiny.devmode = TRUE)` was set).
#' The app will be automatically reloaded whenever the sources change.
#'
#' Additionally, Rhino will automatically rebuild JavaScript and Sass in the background
#' and run R unit tests with the `auto_test_r()` function.
#' Please note that this feature requires Node.js.
#'
#' @param build_sass Boolean. Rebuild Sass automatically in the background?
#' @param build_js Boolean. Rebuild JavaScript automatically in the background?
#' @param run_r_unit_tests Boolean. Run R unit tests automatically in the background?
#' @param auto_test_r_args List. Additional arguments passed to `auto_test_r()`.
#' @param ... Additional arguments passed to `shiny::runApp()`.
#' @return None. This function is called for side effects.
#'
#' @export
devmode <- function(
  build_sass = TRUE,
  build_js = TRUE,
  run_r_unit_tests = TRUE,
  auto_test_r_args = list(reporter = NULL, filter = NULL, hash = TRUE),
  ...
) {
  cli::cli_alert_info("Starting Rhino in devmode...")
  if (build_sass || build_js) {
    npm_command <- Sys.getenv("RHINO_NPM", "npm")
    node_check_and_init(npm_command)
  }

  if (build_sass) {
    cli::cli_alert_info("Starting Sass watcher...")
    sass <- callr::r_bg(function() rhino::build_sass(watch = TRUE), stdout = "", stderr = "")
  }

  if (build_js) {
    cli::cli_alert_info("Starting JS watcher...")
    js <- callr::r_bg(function() rhino::build_js(watch = TRUE), stdout = "", stderr = "")
  }

  if (run_r_unit_tests) {
    cli::cli_alert_info("Starting R unit tests watcher...")
    r_unit_tests <- callr::r_bg(
      function(reporter = NULL, filter = NULL, hash = TRUE) {
        rhino::auto_test_r(reporter = reporter, filter = filter, hash = hash)
      },
      args = auto_test_r_args,
      stdout = "",
      stderr = ""
    )
  }

  on.exit({
    if (build_sass) sass$kill()
    if (build_js) js$kill()
    if (run_r_unit_tests) r_unit_tests$kill()
  })

  shiny::with_devmode(TRUE, shiny::runApp(...))
}
