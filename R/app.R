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
  entrypoint <- read_config()$legacy_entrypoint

  configure_box()
  configure_static()
  configure_logger()

  if (identical(entrypoint, "app_dir")) {
    return(shiny::shinyAppDir("app"))
  }

  make_app(load_main(
    use_source = identical(entrypoint, "source"),
    expect_shiny_module = is.null(entrypoint)
  ))
}

configure_box <- function() {
  # Normally `box.path` is set in `.Rprofile` and used for the whole R session,
  # however `shinytest2` launches the application in a new process which doesn't source `.Rprofile`.
  if (is.null(getOption("box.path"))) {
    options(box.path = getwd())
  }
}

configure_static <- function() {
  shiny::addResourcePath("static", fs::path_wd("app", "static"))
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

load_main <- function(use_source, expect_shiny_module) {
  loader <- function() {
    if (use_source) {
      main <- load_main_source()
    } else {
      main <- load_main_box()
    }
    main <- normalize_main(main, expect_shiny_module)
    list(ui = with_head_tags(main$ui), server = main$server)
  }
  load_main_with_autoreload(loader)
}

load_main_source <- function() {
  main <- new.env(parent = globalenv())
  source(fs::path("app", "main.R"), local = main)
  main
}

load_main_box <- function() {
  # Silence "no visible binding" notes raised by `box::use()` on R CMD check.
  app <- NULL
  main <- NULL
  box::purge_cache()
  box::use(app/main)
  main
}

normalize_main <- function(main, is_module = FALSE) {
  list(
    ui = normalize_ui(main$ui, is_module),
    server = normalize_server(main$server, is_module)
  )
}

normalize_ui <- function(ui, is_module = FALSE) {
  force(ui) # Avoid the pitfalls of lazy evaluation.
  if (is_module) {
    function(request) ui("app")
  } else if (!is.function(ui)) {
    function(request) ui
  } else if (length(formals(ui)) == 0) {
    function(request) ui()
  } else {
    function(request) ui(request)
  }
}

normalize_server <- function(server, is_module = FALSE) {
  force(server) # Avoid the pitfalls of lazy evaluation.
  if (is_module) {
    function(input, output, session) {
      server("app")
    }
  } else if ("session" %in% names(formals(server))) {
    function(input, output, session) {
      server(input = input, output = output, session = session)
    }
  } else {
    function(input, output, session) {
      server(input = input, output = output)
    }
  }
}

with_head_tags <- function(ui) {
  head <- shiny::tags$head(
    react_support(), # Needs to go before `app.min.js`, which defines the React components.
    if (fs::file_exists("app/static/js/app.min.js")) {
      shiny::tags$script(src = "static/js/app.min.js")
    },
    if (fs::file_exists("app/static/css/app.min.css")) {
      shiny::tags$link(rel = "stylesheet", href = "static/css/app.min.css", type = "text/css")
    },
    if (fs::file_exists("app/static/favicon.ico")) {
      shiny::tags$link(rel = "icon", href = "static/favicon.ico", sizes = "any")
    }
  )
  force(ui) # Avoid the pitfalls of lazy evaluation.
  function(request) {
    shiny::tagList(head, ui(request))
  }
}

load_main_with_autoreload <- function(loader) {
  # There are two key components to make `shiny.autoreload` work:
  # 1. When app files are modified, the autoreload callback updates the `main` module in `app_env`.
  # 2. UI and server are functions which retrieve `main` from `app_env` each time they are called.
  #
  # We use the same method both for loading the main module initially and for reloading it.
  # This guarantees consistent behavior regardless of whether user enables `shiny.autoreload`,
  # or calls `shiny::runApp()` each time they want to see changes.
  #
  # We always register an autoreload callback.
  # Shiny just won't call it unless `shiny.autoreload` option is set.

  app_env <- new.env(parent = emptyenv())
  load_main <- function() {
    app_env$main <- loader()
  }

  load_main()
  register_autoreload_callback(load_main)

  list(
    ui = function(request) {
      app_env$main$ui(request)
    },
    server = function(input, output, session) {
      app_env$main$server(input, output, session)
    }
  )
}

register_autoreload_callback <- function(callback) {
  # The autoreload callbacks are not in the public API of Shiny,
  # so we need to be extra careful when using them.
  callbacks <- get0("autoReloadCallbacks", envir = loadNamespace("shiny"))
  if (is.null(callbacks)) {
    cli::cli_alert_warning("Skipping autoreload setup - this version of Shiny doesn't support it.")
    return()
  }

  force(callback) # Avoid the pitfalls of lazy evaluation.
  safe_callback <- function() {
    warn_on_error({
      callback()
    }, "Rhino couldn't reload the main module")
  }

  warn_on_error({
    autoreload_callback$clear()
    autoreload_callback$clear <- callbacks$register(safe_callback)
  }, "Unexpected error while registering an autoreload callback")
}

autoreload_callback <- new.env(parent = emptyenv())
autoreload_callback$clear <- function() NULL

warn_on_error <- function(expr, text) {
  tryCatch(
    expr,
    error = function(condition) {
      cli::cli_alert_warning(paste0(
        text, ": ", conditionMessage(condition)
      ))
    }
  )
}

make_app <- function(main) {
  shiny::shinyApp(
    ui = main$ui,
    server = fix_server(main$server)
  )
}

# A workaround for issues with server reloading:
# https://github.com/Appsilon/rhino/issues/157
#
# For Shiny to reload the app correctly, the body of the server function must meet two criteria:
# 1. It must be wrapped in curly braces.
# 2. It must have source reference information attached, i.e. `srcref` attributes.
fix_server <- function(server) {
  force(server) # Avoid the pitfalls of lazy evaluation.
  eval(parse(
    text = "function(input, output, session) { server(input, output, session) }",
    keep.source = TRUE # Ensure `srcref` attributes are attached.
  ))
}
