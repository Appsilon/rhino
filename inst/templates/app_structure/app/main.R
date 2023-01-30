box::use(
  shiny[bootstrapPage, div, moduleServer, NS, renderText, tags, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    div(
      style = "display: flex; justify-content: center; align-items: center; height: 100vh;",
      tags$h1(
        textOutput(ns("message")),
        tags$a("Check out Rhino docs!", href = "https://appsilon.github.io/rhino/")
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$message <- renderText("Hello!")
  })
}
