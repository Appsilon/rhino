# Make it possible to reload the app without restarting the R session.
purge_box_cache <- function() {
  loaded_mods <- loadNamespace("box")$loaded_mods
  rm(list = ls(loaded_mods), envir = loaded_mods)
}

configure_logger <- function() {
  config <- config::get()
  log_level <- config$rhino_log_level
  log_file <- config$rhino_log_file

  if (!is.null(log_level)) {
    logger::log_threshold(log_level)
  } else {
    cli::cli_alert_warning(
      "Skipping log level configuration, 'rhino_log_level' field not found in config."
    )
  }

  if (!is.null(log_file)) {
    if (!is.na(log_file)) {
      # Use an absolute path to avoid the effects of changing the working directory when the app
      # runs.
      if (!fs::is_absolute_path(log_file)) {
        log_file <- fs::path_wd(log_file)
      }
      logger::log_appender(logger::appender_file(log_file))
    }
  } else {
    cli::cli_alert_warning(
      "Skipping log file configuration, 'rhino_log_file' field not found in config."
    )
  }
}

load_main_module <- function() {
  # Silence "no visible binding" notes raised by `box::use()` on R CMD check.
  app <- NULL
  main <- NULL
  box::use(app/main)
  main
}

as_top_level <- function(shiny_module) {
  # Necessary to avoid infinite recursion / bugs due to lazy evaluation:
  # https://adv-r.hadley.nz/function-factories.html?q=force#forcing-evaluation
  force(shiny_module)

  # The actual function must be sourced with `keep.source = TRUE` for reloading to work:
  # https://github.com/Appsilon/rhino/issues/157
  wrap <- source(fs::path_package("rhino", "as_top_level.R"), keep.source = TRUE)$value

  wrap(shiny_module)
}

attach_head_tags <- function(ui) {
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$script(src = "static/js/app.min.js"),
      shiny::tags$link(rel = "stylesheet", href = "static/css/app.min.css", type = "text/css"),
      shiny::tags$link(rel = "icon", href = "static/favicon.ico", sizes = "any")
    ),
    ui
  )
}

with_head_tags <- function(ui) {
  # The top-level UI must be a function for Shiny bookmarking to work.
  if (is.function(ui)) function(request) attach_head_tags(ui(request))
  else attach_head_tags(ui)
}

#' Rhino application
#'
#' The entrypoint for a Rhino application.
#' Your `app.R` should contain nothing but a call to `rhino::app()`.
#'
#' This function is a wrapper around `shiny::shinyApp()`.
#' It reads `rhino.yml` and performs some configuration steps (logger, static files, box modules).
#' You can run a Rhino application in typical fashion using `shiny::runApp()`.
#'
#' Rhino will load the `app/main.R` file as a box module (`box::use(app/main)`).
#' It should export two functions which take a single `id` argument -
#' the `ui` and `server` of your top-level Shiny module.
#'
#' # Legacy entrypoint
#'
#' It is possible to specify a different way to load your application
#' using the `legacy_entrypoint` option in `rhino.yml`:
#' 1. `app_dir`: Rhino will run the app using `shiny::shinyAppDir("app")`.
#' 2. `source`: Rhino will `source("app/main.R")`.
#' This file should define the top-level `ui` and `server` objects to be passed to `shinyApp()`.
#' 3. `box_top_level`: Rhino will load `app/main.R` as a box module (as it does by default),
#' but the exported `ui` and `server` objects will be considered as top-level.
#'
#' The `legacy_entrypoint` setting is useful when migrating an existing Shiny application to Rhino.
#' It is recommended to transform your application step by step:
#' 1. With `app_dir` you should be able to run your application right away
#' (just put the files in the `app` directory).
#' 2. With `source` setting your application structure must be brought closer to Rhino,
#' but you can still use `library()` and `source()` functions.
#' 3. With `box_top_level` you can be confident that the whole app is properly modularized,
#' as box modules can only load other box modules (`library()` and `source()` won't work).
#' 4. The last step is to remove the `legacy_entrypoint` setting completely.
#' Compared to `box_top_level` you'll need to make your top-level `ui` and `server`
#' into a [Shiny module](https://shiny.rstudio.com/articles/modules.html)
#' (functions taking a single `id` argument).
#'
#' @return An object representing the app (can be passed to `shiny::runApp()`).
#'
#' @examples
#' \dontrun{
#'   # Your `app.R` should contain nothing but this single call:
#'   rhino::app()
#' }
#' @export
app <- function() {
  purge_box_cache()
  configure_logger()
  shiny::addResourcePath("static", fs::path_wd("app", "static"))

  entrypoint <- read_config()$legacy_entrypoint
  if (identical(entrypoint, "app_dir")) {
    return(shiny::shinyAppDir("app"))
  }

  if (identical(entrypoint, "source")) {
    main <- new.env()
    source(fs::path("app", "main.R"), local = main)
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
