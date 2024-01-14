node_path <- function(...) {
  fs::path(".rhino", ...)
}

# Run `npm`/`bun` command (assume node directory already exists in the project).
js_package_manager_raw <- function(..., status_ok = 0) {
  command <- Sys.getenv("RHINO_NPM", "npm")
  withr::with_dir(node_path(), {
    status <- system2(command = command, args = c(...))
  })
  if (status != status_ok) {
    cli::cli_abort("System command '{command}' exited with status {status}.")
  }
}

# Run `npm`/`bun` command (create node directory in the project if needed).
js_package_manager <- function(...) {
  command <- Sys.getenv("RHINO_NPM", "npm")
  display_name <- ifelse(command == "npm", "Node.js", command)
  check_system_dependency(
    cmd = command,
    dependency_name = display_name,
    documentation_url = "https://go.appsilon.com/rhino-system-dependencies"
  )
  init_js_package_manager()
  js_package_manager_raw(...)
}

init_js_package_manager <- function() {
  command <- Sys.getenv("RHINO_NPM", "npm")
  if (!fs::dir_exists(node_path())) {
    message("Initializing Javascript configs\u2026")
    copy_template("node", node_path())
  }

  # existing .rhino and missing node_modules folder
  # indicate that packages were not installed but rhino project initialized
  if (!fs::dir_exists(node_path("node_modules"))) {
    message("Installing dependencies by ", command, "\u2026")
    js_package_manager_raw("install", "--no-audit", "--no-fund")
  }
}
