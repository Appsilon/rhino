# `box` library separate packages and module imports linter

Checks that packages and modules are imported in separate
[`box::use()`](https://klmr.me/box/reference/use.html) statements. See
the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Usage

``` r
box_separate_calls_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(package, path/to/file)",
  linters = box_separate_calls_linter()
)
#> Error in box_separate_calls_linter(): could not find function "box_separate_calls_linter"

lintr::lint(
  text = "box::use(path/to/file, package)",
  linters = box_separate_calls_linter()
)
#> Error in box_separate_calls_linter(): could not find function "box_separate_calls_linter"

# okay
lintr::lint(
  text = "box::use(package1, package2)
    box::use(path/to/file1, path/to/file2)",
  linters = box_separate_calls_linter()
)
#> Error in box_separate_calls_linter(): could not find function "box_separate_calls_linter"
```
