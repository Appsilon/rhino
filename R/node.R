node_path <- function(...) {
  fs::path(".rhino", ...)
}

# Run `npm` or an alternative command specified by `RHINO_NPM`.
# If needed, copy over Node.js template and install dependencies.
npm <- function(...) {
  npm_command <- Sys.getenv("RHINO_NPM", "npm")
  check_system_dependency(
    cmd = npm_command,
    dependency_name = ifelse(npm_command == "npm", "Node.js", npm_command),
    documentation_url = "https://go.appsilon.com/rhino-system-dependencies"
  )
  node_init(npm_command)
  node_run(npm_command, ...)
}

node_init <- function(npm_command) {
  if (!fs::dir_exists(node_path())) {
    cli::cli_alert_info("Initializing Node.js directory...")
    copy_template("node", node_path())
  }
  if (!fs::dir_exists(node_path("node_modules"))) {
    cli::cli_alert_info("Installing Node.js packages with {npm_command}...")
    node_run(npm_command, "install", "--no-audit", "--no-fund")
  }
}

# Run the specified command in Node.js directory (assume it already exists).
node_run <- function(command, ..., status_ok = 0) {
  withr::with_dir(node_path(), {
    status <- system2(command = command, args = c(...))
  })
  if (status != status_ok) {
    cli::cli_abort("System command '{command}' exited with status {status}.")
  }
}
