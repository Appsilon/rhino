app <- function() {
  sass_enabled <- "sass" %in% names(read_config()$features)

  # Purge the box module cache, so the app can be reloaded without restarting the R session.
  rm(list = ls(box:::loaded_mods), envir = box:::loaded_mods)
  box::use(r/main)

  shiny::addResourcePath("static", "app/static")
  shiny::shinyApp(
    ui = shiny::tagList(
      if (sass_enabled) shiny::tags$head(
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "static/css/app.min.css"),
      ),
      main$ui("app")
    ),
    server = function(input, output) {
      main$server("app")
    }
  )
}
