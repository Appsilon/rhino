box::use(
  shiny[bootstrapPage, moduleServer, NS, renderText, tags, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    tags$head(
      tags$link(rel = "icon", href = "static/favicon.ico", sizes = "any")
      tags$link(rel = "stylesheet", type = "text/css", href = "static/css/app.min.css"),
    ),
    tags$h3(
      textOutput(ns("message"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$message <- renderText("Hello!")
  })
}
