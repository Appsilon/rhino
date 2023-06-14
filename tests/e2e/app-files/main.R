box::use(
  shiny,
  rhino[log]
)

box::use(app / view / hello)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  hello$ui(ns("hello"))
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    log$trace("This is a test")
    hello$server("hello")
  })
}
