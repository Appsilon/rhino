box::use(
  shiny,
  rhino[log, react_component]
)

box::use(app / view / hello)

Box <- react_component("Box") # nolint object_name_linter

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$tagList(
    Box(id = ns("box"), shiny$p("React works!")),
    hello$ui(ns("hello"))
  )
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    log$trace("This is a test")
    hello$server("hello")
  })
}
