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

as_top_level <- function(shiny_module) {
  list(
    ui = shiny_module$ui("app"),
    server = function(input, output) shiny_module$server("app")
  )
}

with_head_tags <- function(ui) {
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$script(src = "static/js/app.min.js"),
      shiny::tags$link(rel = "stylesheet", href = "static/css/app.min.css", type = "text/css"),
      shiny::tags$link(rel = "icon", href = "static/favicon.ico", sizes = "any")
    ),
    ui
  )
}

app <- function() {
  configure_logger()
  shiny::addResourcePath("static", "app/static")

  entrypoint <- read_config()$legacy_entrypoint
  if (identical(entrypoint, "app_dir")) {
    return(shiny::shinyAppDir("app"))
  }

  if (identical(entrypoint, "source")) {
    main <- new.env()
    source(fs::path("app", "r", "main.R"), local = main)
  } else {
    main <- load_main_module()
    if (!identical(entrypoint, "box_top_level")) {
      main <- as_top_level(main)
    }
  }
  shiny::shinyApp(
    ui = with_head_tags(main$ui),
    server = main$server
  )
}
