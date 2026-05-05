# Rhino application

The entrypoint for a Rhino application. Your `app.R` should contain
nothing but a call to `rhino::app()`.

## Usage

``` r
app()
```

## Value

An object representing the app (can be passed to
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)).

## Details

This function is a wrapper around
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html). It
reads `rhino.yml` and performs some configuration steps (logger, static
files, box modules). You can run a Rhino application in typical fashion
using [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

Rhino will load the `app/main.R` file as a box module
(`box::use(app/main)`). It should export two functions which take a
single `id` argument - the `ui` and `server` of your top-level Shiny
module.

## Legacy entrypoint

It is possible to specify a different way to load your application using
the `legacy_entrypoint` option in `rhino.yml`:

1.  `app_dir`: Rhino will run the app using `shiny::shinyAppDir("app")`.

2.  `source`: Rhino will `source("app/main.R")`. This file should define
    the top-level `ui` and `server` objects to be passed to
    `shinyApp()`.

3.  `box_top_level`: Rhino will load `app/main.R` as a box module (as it
    does by default), but the exported `ui` and `server` objects will be
    considered as top-level.

The `legacy_entrypoint` setting is useful when migrating an existing
Shiny application to Rhino. It is recommended to transform your
application step by step:

1.  With `app_dir` you should be able to run your application right away
    (just put the files in the `app` directory).

2.  With `source` setting your application structure must be brought
    closer to Rhino, but you can still use
    [`library()`](https://rdrr.io/r/base/library.html) and
    [`source()`](https://rdrr.io/r/base/source.html) functions.

3.  With `box_top_level` you can be confident that the whole app is
    properly modularized, as box modules can only load other box modules
    ([`library()`](https://rdrr.io/r/base/library.html) and
    [`source()`](https://rdrr.io/r/base/source.html) won't work).

4.  The last step is to remove the `legacy_entrypoint` setting
    completely. Compared to `box_top_level` you'll need to make your
    top-level `ui` and `server` into a [Shiny
    module](https://shiny.rstudio.com/articles/modules.html) (functions
    taking a single `id` argument).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Your `app.R` should contain nothing but this single call:
  rhino::app()
} # }
```
