node_path <- function(...) {
  fs::path(".rhino", ...)
}

npm_command <- function() {
  Sys.getenv("RHINO_NPM", "npm")
}

# Run a script defined in `package.json`.
npm_run <- function(...) {
  # Use `--silent` to prevent `npm` from echoing the command it runs.
  # The output of the script itself will still be displayed.
  npm("--silent", "run", ...)
}

# Run `npm` or an alternative command specified by `RHINO_NPM`.
# If needed, copy over Node.js template and install dependencies.
npm <- function(...) {
  node <- node_check()
  if (!node$status_ok) {
    node_missing(abort = TRUE)
  }
  node_init()
  node_run(..., wd = node_path())
}

node_check <- function() {
  version <- tryCatch(
    node_run("--version", stdout = "|")$stdout,
    error = function(e) NULL
  )
  list(
    status_ok = !is.null(version),
    diagnostic_info = paste(npm_command(), ifelse(is.null(version), "failed", trimws(version)))
  )
}

node_missing <- function(info = NULL, abort = FALSE) {
  docs_url <- "https://go.appsilon.com/rhino-system-dependencies" # nolint object_usage_linter
  msg <- c(
    "!" = "Failed to run system command {.code {npm_command()}}.",
    " " = "Do you have Node.js installed? Read more: {.url {docs_url}}",
    "i" = info
  )
  if (abort) {
    cli::cli_abort(msg)
  } else {
    cli::cli_bullets(msg)
  }
}

node_init <- function() {
  if (!fs::dir_exists(node_path())) {
    cli::cli_alert_info("Initializing Node.js directory...")
    copy_template("node", node_path())
  }
  if (!fs::dir_exists(node_path("node_modules"))) {
    cli::cli_alert_info("Installing Node.js packages with {.code {npm_command()}}...")
    node_run("install", "--no-audit", "--no-fund", wd = node_path())
  }
}

# Run the specified command in Node.js directory (assume it already exists).
node_run <- function(..., stdout = NULL, wd = NULL, background = FALSE) {
  if (background) {
    run <- processx::process$new
  } else {
    run <- processx::run
  }

  # Workaround: {processx} cannot find `npm` on Windows, but it works with a shell.
  if (.Platform$OS.type == "windows") {
    command <- "cmd"
    args <- rlang::chr("/c", npm_command(), ...)
  } else {
    command <- npm_command()
    args <- rlang::chr(...)
  }

  run(
    command = command,
    args = args,
    stdout = stdout,
    wd = wd
  )
}
