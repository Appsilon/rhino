box::use(shiny)

box::use(app / view / hello)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  hello$ui(ns("hello"))
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    hello$server("hello")
  })
}
