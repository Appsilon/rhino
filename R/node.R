node_path <- function(...) {
  fs::path(".rhino", ...)
}

add_node <- function(clean = FALSE) {
  if (clean && fs::dir_exists(node_path())) {
    fs::dir_delete(node_path())
  }
  copy_template("node", node_path())
}

# Run `npm`/`bun` command (assume node directory already exists in the project).
js_package_manager_raw <- function(..., status_ok = 0) {
  command <- read_config()$js_package_manager
  withr::with_dir(node_path(), {
    status <- system2(command = command, args = c(...))
  })
  if (status != status_ok) {
    cli::cli_abort("System command '{command}' exited with status {status}.")
  }
}

# Run `npm`/`bun` command (create node directory in the project if needed).
js_package_manager <- function(...) {
  command <- read_config()$js_package_manager
  display_names <- list(
    npm = "Node.js",
    bun = "Bun"
  )
  check_system_dependency(
    cmd = command,
    dependency_name = display_names[[command]],
    documentation_url = "https://go.appsilon.com/rhino-system-dependencies"
  )
  if (!fs::dir_exists(node_path())) {
    add_node()
    js_package_manager_raw(command, "install", "--no-audit", "--no-fund")
  }
  js_package_manager_raw(...)
}
