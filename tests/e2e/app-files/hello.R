box::use(
  shiny,
)

box::use(
  app/logic/say_hello[say_hello],
)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$bootstrapPage(
    shiny$tags$div(
      class = "input-and-click",
      shiny$textInput(ns("name"), label = NULL, value = NULL),
      shiny$actionButton(ns("say_hello"), label = "Say Hello")
    ),
    shiny$textOutput(ns("message"))
  )
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    ns <- session$ns

    shiny$observe({
      is_name_empty <- is.null(input$name) || input$name == ""

      session$sendCustomMessage(
        "toggleDisable",
        list(id = paste0("#", ns("say_hello")), disable = is_name_empty)
      )
    })

    shiny$observeEvent(
      input$say_hello, {
        output$message <- shiny$renderText(say_hello(shiny$isolate(input$name)))
      }
    )
  })
}
