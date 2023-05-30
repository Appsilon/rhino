box::use(
  shiny[
    bootstrapPage,
    NS,
    tags,
    textInput,
    actionButton,
    observeEvent,
    textOutput,
    moduleServer,
    observe,
    renderText,
    isolate
  ],
)

box::use(app / view / hello)

#' @export
ui <- function(id) {
  ns <- NS(id)
  hello$ui(ns("hello"))
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    hello$server("hello")
  })
}
