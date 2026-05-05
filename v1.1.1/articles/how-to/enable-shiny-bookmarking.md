# How-to: Enable Shiny bookmarking

To use Shiny
[bookmarking](https://shiny.rstudio.com/articles/bookmarking-state.html),
call
[`shiny::enableBookmarking()`](https://rdrr.io/pkg/shiny/man/enableBookmarking.html)
somewhere in your `main.R`:

``` r
box::use(
  shiny,
)

shiny$enableBookmarking()

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$bootstrapPage(
    shiny$bookmarkButton(),
    shiny$textInput(ns("name"), "Name"),
    shiny$textOutput(ns("message"))
  )
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    output$message <- shiny$renderText(paste0("Hello ", input$name, "!"))
  })
}
```

If you are using a [legacy
entrypoint](https://appsilon.github.io/rhino/reference/app.html#legacy-entrypoint),
be sure to make your UI a function as described in the details section
of
[`shiny::enableBookmarking()`](https://rdrr.io/pkg/shiny/man/enableBookmarking.html).
