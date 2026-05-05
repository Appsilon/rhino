# `box` library trailing commas linter

Checks that all `box:use` imports have a trailing comma. This applies to
package or module imports between `(` and `)`, and, optionally, function
imports between `[` and `]`. Take note that
[`lintr::commas_linter()`](https://lintr.r-lib.org/reference/commas_linter.html)
may come into play. See the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Usage

``` r
box_trailing_commas_linter(check_functions = FALSE)
```

## Arguments

- check_functions:

  Boolean flag to include function imports between `[` and `]`. Defaults
  to FALSE.

## Value

A custom linter function for use with `r-lib/lintr`

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(base, rlang)",
  linters = box_trailing_commas_linter()
)
#> Error in box_trailing_commas_linter(): could not find function "box_trailing_commas_linter"

lintr::lint(
  text = "box::use(
   dplyr[select, mutate]
  )",
  linters = box_trailing_commas_linter()
)
#> Error in box_trailing_commas_linter(): could not find function "box_trailing_commas_linter"

# okay
lintr::lint(
  text = "box::use(base, rlang, )",
  linters = box_trailing_commas_linter()
)
#> Error in box_trailing_commas_linter(): could not find function "box_trailing_commas_linter"

lintr::lint(
  text = "box::use(
    dplyr[select, mutate],
  )",
  linters = box_trailing_commas_linter()
)
#> Error in box_trailing_commas_linter(): could not find function "box_trailing_commas_linter"
```
