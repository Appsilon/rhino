box::use(
  shiny[bootstrapPage, moduleServer, NS, renderText, tags, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
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
