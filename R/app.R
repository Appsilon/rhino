configure_logger <- function() {
  log_level <- Sys.getenv("LOG_LEVEL", unset = "INFO")
  log_file <- Sys.getenv("LOG_FILE", unset = NA)

  logger::log_threshold(log_level)
  if (!is.na(log_file)) {
    logger::log_appender(logger::appender_file(log_file))
  }
}

load_main_module <- function() {
  # Purge the box module cache, so the app can be reloaded without restarting the R session.
  loaded_mods <- loadNamespace("box")$loaded_mods
  rm(list = ls(loaded_mods), envir = loaded_mods)

  # Silence "no visible binding" notes on R CMD check.
  r <- NULL
  main <- NULL

  box::use(r/main)
  main
}

app <- function() {
  configure_logger()
  shiny::addResourcePath("static", "app/static")

  entrypoint <- read_config()$legacy_entrypoint
  if (is.null(entrypoint)) {
    main <- load_main_module()
    shiny::shinyApp(
      ui = main$ui("app"),
      server = function(input, output) main$server("app")
    )
  } else if (entrypoint == "box_top_level") {
    main <- load_main_module()
    shiny::shinyApp(ui = main$ui, server = main$server)
  } else if (entrypoint == "source") {
    env <- new.env()
    source(fs::path("app", "r", "main.R"), local = env)
    shiny::shinyApp(ui = env$ui, server = env$server)
  } else if (entrypoint == "app_dir") {
    shiny::shinyAppDir("app")
  }
}
