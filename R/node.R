node_path <- function(...) {
  fs::path(".rhino", ...)
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
    node_missing(node$npm_command, abort = TRUE)
  }
  node_init(node$npm_command)
  node_run(node$npm_command, ...)
}

node_check <- function() {
  npm_command <- Sys.getenv("RHINO_NPM", "npm")
  version <- tryCatch(
    processx::run(npm_command, "--version")$stdout,
    error = function(e) NULL
  )
  list(
    npm_command = npm_command,
    status_ok = !is.null(version),
    diagnostic_info = paste(npm_command, ifelse(is.null(version), "failed", trimws(version)))
  )
}

node_missing <- function(npm_command, info = NULL, abort = FALSE) {
  docs_url <- "https://go.appsilon.com/rhino-system-dependencies" # nolint object_usage_linter
  msg <- c(
    "!" = "Failed to run system command {.code {npm_command}}.",
    " " = "Do you have Node.js installed? Read more: {.url {docs_url}}",
    "i" = info
  )
  if (abort) {
    cli::cli_abort(msg)
  } else {
    cli::cli_bullets(msg)
  }
}

node_init <- function(npm_command) {
  if (!fs::dir_exists(node_path())) {
    cli::cli_alert_info("Initializing Node.js directory...")
    copy_template("node", node_path())
  }
  if (!fs::dir_exists(node_path("node_modules"))) {
    cli::cli_alert_info("Installing Node.js packages with {.code {npm_command}}...")
    node_run(npm_command, "install", "--no-audit", "--no-fund")
  }
}

# Run the specified command in Node.js directory (assume it already exists).
node_run <- function(command, ..., background = FALSE) {
  args <- list(
    command = command,
    args = rlang::chr(...),
    wd = node_path(),
    stdin = NULL,
    stdout = "",
    stderr = ""
  )
  if (background) {
    do.call(processx::process$new, args)
  } else {
    do.call(processx::run, args)
    invisible()
  }
}
