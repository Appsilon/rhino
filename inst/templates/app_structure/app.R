# Purge the box module cache, so the app can be reloaded without restarting the R session.
rm(list = ls(box:::loaded_mods), envir = box:::loaded_mods)

box::use(
  logger[appender_file, log_appender, log_threshold],
  shiny[addResourcePath, shinyApp],
)
box::use(
  r/main,
)

# nolint start
LOG_FILE <- Sys.getenv("LOG_FILE")
LOG_LEVEL <- Sys.getenv("LOG_LEVEL", unset = "INFO")
# nolint end

addResourcePath("static", "app/static")

log_threshold(LOG_LEVEL)
if (nzchar(LOG_FILE)) {
  log_appender(appender_file(LOG_FILE))
}

shinyApp(
  ui = main$ui("app"),
  server = function(input, output) {
    main$server("app")
  }
)
