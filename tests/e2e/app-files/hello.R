box::use(
  shiny[           # nolint
    actionButton,
    bootstrapPage,
    isolate,
    moduleServer,
    NS,
    observe,
    observeEvent,
    renderText,
    tags,
    textInput,
    textOutput
  ],
)

box::use(app/logic/say_hello[say_hello], )

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    tags$div(
      class = "input-and-click",
      textInput(ns("name"), label = NULL, value = NULL),
      actionButton(ns("say_hello"), label = "Say Hello")
    ),
    textOutput(ns("message"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      is_name_empty <- is.null(input$name) || input$name == ""

      session$sendCustomMessage(
        "toggleDisable",
        list(id = paste0("#", ns("say_hello")), disable = is_name_empty)
      )
    })

    observeEvent(
      input$say_hello, {
        output$message <- renderText(say_hello(isolate(input$name)))
      }
    )
  })
}
