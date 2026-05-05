# `box` library universal import linter

Checks that all function imports are explicit. `package[...]` is not
used. See the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Usage

``` r
box_universal_import_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(base[...])",
  linters = box_universal_import_linter()
)
#> Error in box_universal_import_linter(): could not find function "box_universal_import_linter"

lintr::lint(
  text = "box::use(path/to/file[...])",
  linters = box_universal_import_linter()
)
#> Error in box_universal_import_linter(): could not find function "box_universal_import_linter"

# okay
lintr::lint(
  text = "box::use(base[print])",
  linters = box_universal_import_linter()
)
#> Error in box_universal_import_linter(): could not find function "box_universal_import_linter"

lintr::lint(
  text = "box::use(path/to/file[do_something])",
  linters = box_universal_import_linter()
)
#> Error in box_universal_import_linter(): could not find function "box_universal_import_linter"
```
