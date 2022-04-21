box::use(
  shiny[moduleServer, NS]
)

#' @export
ui <- function(id) {
  ns <- NS(id)

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}
