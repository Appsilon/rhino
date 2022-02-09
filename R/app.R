app <- function() {
  # Purge the box module cache, so the app can be reloaded without restarting the R session.
  rm(list = ls(box:::loaded_mods), envir = box:::loaded_mods)
  box::use(r/main)
  shiny::addResourcePath("static", "app/static")
  shiny::shinyApp(
    ui = main$ui("app"),
    server = function(input, output) {
      main$server("app")
    }
  )
}
