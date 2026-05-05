# Development mode

Run application in development mode with automatic rebuilding and
reloading.

## Usage

``` r
devmode(
  build_sass = TRUE,
  build_js = TRUE,
  run_r_unit_tests = TRUE,
  auto_test_r_args = list(reporter = NULL, filter = NULL, hash = TRUE),
  ...
)
```

## Arguments

- build_sass:

  Boolean. Rebuild Sass automatically in the background?

- build_js:

  Boolean. Rebuild JavaScript automatically in the background?

- run_r_unit_tests:

  Boolean. Run R unit tests automatically in the background?

- auto_test_r_args:

  List. Additional arguments passed to
  [`auto_test_r()`](https://appsilon.github.io/rhino/reference/auto_test_r.md).

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

None. This function is called for side effects.

## Details

This function will launch the Shiny app in [development
mode](https://shiny.posit.co/r/reference/shiny/latest/devmode.html) (as
if `options(shiny.devmode = TRUE)` was set). The app will be
automatically reloaded whenever the sources change.

Additionally, Rhino will automatically rebuild JavaScript and Sass in
the background and run R unit tests with the
[`auto_test_r()`](https://appsilon.github.io/rhino/reference/auto_test_r.md)
function. Please note that this feature requires Node.js.
