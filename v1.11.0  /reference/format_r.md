# Format R

Uses the `{styler}` and `{box.linters}` packages to automatically format
R sources. As with `styler`, carefully examine the results after running
this function.

## Usage

``` r
format_r(paths, exclude_files = NULL, ...)
```

## Arguments

- paths:

  Character vector of files and directories to format.

- exclude_files:

  Character vector with regular expressions of files that should be
  excluded from styling.

- ...:

  Optional arguments to pass to `box.linters::style_*` functions.

## Value

None. This function is called for side effects.

## Details

The code is formatted according to the
[`styler::tidyverse_style`](https://styler.r-lib.org/reference/tidyverse_style.html)
guide with one adjustment: spacing around math operators is not modified
to avoid conflicts with
[`box::use()`](https://klmr.me/box/reference/use.html) statements.

If available, [`box::use()`](https://klmr.me/box/reference/use.html)
calls are reformatted by styling functions provided by `{box.linters}`.
These include:

- Separating [`box::use()`](https://klmr.me/box/reference/use.html)
  calls for packages and local modules

- Alphabetically sorting packages, modules, and functions.

- Adding trailing commas

`box.linters::style_*` functions require the `treesitter` and
`treesitter.r` packages. These, in turn, require R \>= 4.3.0.
`format_r()` will continue to operate without these but will not perform
[`box::use()`](https://klmr.me/box/reference/use.html) call styling.

For more information on
[`box::use()`](https://klmr.me/box/reference/use.html) call styling
please refer to the `{box.linters}` styling functions
[documentation](https://appsilon.github.io/box.linters/reference/style_box_use_text.html).

## Examples

``` r
if (interactive()) {
  # Format a single file.
  format_r("app/main.R")

  # Format all files in a directory.
  format_r("app/view")
}
```
