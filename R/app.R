app <- function() {
  # Purge the box module cache, so the app can be reloaded without restarting the R session.
  rm(list = ls(box:::loaded_mods), envir = box:::loaded_mods)

  log_file <- Sys.getenv("LOG_FILE")
  log_level <- Sys.getenv("LOG_LEVEL", unset = "INFO")

  logger::log_threshold(log_level)
  if (nzchar(log_file)) {
    logger::log_appender(logger::appender_file(log_file))
  }

  shiny::addResourcePath("static", "app/static")

  box::use(r/main)
  shiny::shinyApp(
    ui = main$ui("app"),
    server = function(input, output) {
      main$server("app")
    }
  )
}
