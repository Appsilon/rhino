# How-to: Write R code

This article is a stub. We are working to edit and expand it.

The entrypoint to your application is the `app/main.R` file. It can load
packages and other files with
[`box::use()`](https://klmr.me/box/reference/use.html). You should not
use `::`, [`library()`](https://rdrr.io/r/base/library.html) and
[`source()`](https://rdrr.io/r/base/source.html) calls in your code.

Each file should have two
[`box::use()`](https://klmr.me/box/reference/use.html) statements at the
top (one for packages and one for modules). Avoid `...`. Sort entries
alphabetically.

Each file in `app/view` should be a box + Shiny module. See `app/main.R`
for example.
