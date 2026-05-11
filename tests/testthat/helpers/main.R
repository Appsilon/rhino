box::use(
  shiny[NS, bootstrapPage, div, moduleServer, renderUI, tags, uiOutput],
)

box::use(
  app/logic/hello[hello],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    uiOutput(ns("message"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$message <- renderUI({
      div(
        style = "display: flex; justify-content: center; align-items: center; height: 100vh;",
        tags$h1(
          tags$a(
            hello(),
            href = "https://appsilon.github.io/rhino/"
          )
        )
      )
    })
  })
}
