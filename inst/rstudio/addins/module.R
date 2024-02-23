box::use(
  shiny,
)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)

}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {

  })
}
