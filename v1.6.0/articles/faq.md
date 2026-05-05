# FAQ

## Running and deployment

How to run a Rhino application?

You can run a Rhino application exactly the same as a regular Shiny app:

- using [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)
- using the “Run app” button in RStudio

How to use a specific port when running a Rhino application?

You can:

- set port in
  [`shiny::runApp`](https://rdrr.io/pkg/shiny/man/runApp.html),
  e.g. `shiny:runApp(port = 5000)`
- add `options(shiny.port = 5000)` to your `.Rprofile` file

More details can be found in [How-to: Set application run
parameters](https://appsilon.github.io/rhino/v1.6.0/articles/how-to/set-application-run-parameters.md).

How to deploy a Rhino application?

The same as in the case of a regular Shiny app, e.g. you can use
“Deploy” button in RStudio IDE.

## Differences between Rhino and vanilla Shiny

Where are `server.R` and `ui.R` files?

Instead of `server.R` and `ui.R`, Rhino uses a single file `app/main.R`.
It includes both the server and UI part of the application. The main
difference is that both are already Shiny modules so you need to use
namespace (`ns`) in the UI part.

Where is the `global.R` file?

Rhino encourages you to work with encapsulated modules instead of using
global objects, thus it does not include `global.R` file. Instead,
objects are by default only available on the level of a particular
script. Depending on the context, objects can be shared explicitly, by
being passed as an argument or being exported with `@export`.

Where should I put `library` calls?

Rhino application doesn’t use `library` to load packages. Instead, each
script imports its dependencies with
[`box::use`](https://klmr.me/box/reference/use.html):

``` r
box::use(
  dplyr, # functions from `dplyr` are available using `$`, e.g. `dplyr$mutate()`
  shiny[div, moduleServer, NS], # `div`, `moduleServer`, and `NS` are available (but other functions from `shiny` are not)
)
```

The only place where you should use `library` calls is the
`dependencies.R` file. You can read more about managing R dependencies
in [this
article](https://appsilon.github.io/rhino/articles/how-to/manage-r-dependencies.html).

Where is the `www` directory?

Instead of `www`, Rhino uses `app/static`. To utilize it, you need to
provide the path to your assets that include `static`, for example:

    img(src = "static/images/appsilon-logo.png")

## Common problems

Why doesn’t my `input` trigger the reactive chain?

Rhino uses Shiny modules to encapsulate the whole application, so the
`id` of every input you create needs to be wrapped in `ns`, for example:

``` r
box::use(
  shiny[NS, textInput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  textInput(
    inputId = ns("my_input"),
    label = "My Input"
  )
}
```

Why is my `output` not visible?

Rhino uses Shiny modules to encapsulate the whole application, so the
`id` of every output you create needs to be wrapped in `ns`, for
example:

``` r
box::use(
  shiny[moduleServer, NS, renderText, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  textOutput(ns("text"))
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$text <- renderText("This is a message!")
  })
}
```

`shinyBS` is not working in my Rhino application.

`shinyBS` uses the `.onAttach()` hook to call
[`shiny::addResourcePath()`](https://rdrr.io/pkg/shiny/man/resourcePaths.html)
which is necessary for its resources (JS and CSS) to be loaded
correctly. This hook is never run with
[`box::use()`](https://klmr.me/box/reference/use.html) (normally a
[`library()`](https://rdrr.io/r/base/library.html) call would run it).
It is worth noting that the problem will be also present in vanilla
Shiny if you only use `::` to access `shinyBS` functions (`shinyBS`
should use `.onLoad()` instead).

*Workaround:* Add the following snippet to your `app/main.R` (just below
the [`box::use()`](https://klmr.me/box/reference/use.html) statements is
a good place):

``` r
# Run the `.onAttach` hook (shinyBS uses it to add a Shiny resource path).
suppressWarnings(library(shinyBS))
```

You’ll still need to explicitly
[`box::use()`](https://klmr.me/box/reference/use.html) whatever
functions you need from `shinyBS`
([`library()`](https://rdrr.io/r/base/library.html) doesn’t work in a
box module).

More details can be found
[here](https://github.com/Appsilon/rhino/discussions/279).

I have an R package installed, but `renv::snapshot()` didn’t add it to
the `renv.lock` file.

In Rhino, `renv` only uses packages added to the `dependencies.R` file.
This way you have full control over what libraries are used by your
application. Adding `library(your package name)` to the `dependencies.R`
file should fix the problem.

Check also:

- [`renv`
  configuration](https://appsilon.github.io/rhino/articles/explanation/renv-configuration.html)
- [dependencies
  management](https://appsilon.github.io/rhino/articles/how-to/manage-r-dependencies.html).

## Styling Rhino application

Can I use multiple Sass files?

Yes, you can have any file/directory structure in `app/styles` that you
desire. The `app/styles/main.scss` is the entry point: you’ll need to
[`@use`](https://sass-lang.com/documentation/at-rules/use) the other
files from `main.scss`. Then running
[`rhino::build_sass()`](https://appsilon.github.io/rhino/v1.6.0/reference/build_sass.md)
will be sufficient to include the styles in your application.
