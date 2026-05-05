# `box` library function import count linter

Checks that function imports do not exceed the defined `max`. See the
[Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Usage

``` r
box_func_import_count_linter(max = 8L)
```

## Arguments

- max:

  Maximum function imports allowed between `[` and `]`. Defaults to 8.

## Value

A custom linter function for use with `r-lib/lintr`.

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(package[one, two, three, four, five, six, seven, eight, nine])",
  linters = box_func_import_count_linter()
)
#> Error in box_func_import_count_linter(): could not find function "box_func_import_count_linter"

lintr::lint(
  text = "box::use(package[one, two, three, four])",
  linters = box_func_import_count_linter(3)
)
#> Error in box_func_import_count_linter(3): could not find function "box_func_import_count_linter"

# okay
lintr::lint(
  text = "box::use(package[one, two, three, four, five])",
  linters = box_func_import_count_linter()
)
#> Error in box_func_import_count_linter(): could not find function "box_func_import_count_linter"

lintr::lint(
  text = "box::use(package[one, two, three])",
  linters = box_func_import_count_linter(3)
)
#> Error in box_func_import_count_linter(3): could not find function "box_func_import_count_linter"
```
