system_npm <- function(..., status_ok = 0) {
  withr::with_dir(node_path(), {
    status <- system2(command = "npm", args = c(...))
  })
  if (status != status_ok) {
    cli::cli_abort("System command 'npm' exited with status {status}.")
  }
}

link_root_mklink <- function() {
  tryCatch({
    system2("cmd.exe", input = "mklink root ..\\..", stdout = TRUE, stderr = TRUE)
  }, error = function(error) {
    cli::cli_abort(c(
      "Node.js setup: Failed to create root link with {.code mklink}: {error$message}",
      i = "You might need to enable Developer Mode: https://go.appsilon.com/rhino-windows"
    ))
  })
}

link_root_fs <- function() {
  tryCatch({
    fs::link_create(path = fs::path("..", ".."), new_path = "root")
  }, error = function(error) {
    cli::cli_abort(
      "Node.js setup: Failed to create root link with {.pkg fs}: {error$message}"
    )
  })
}

is_windows <- function() {
  Sys.info()[["sysname"]] == "Windows"
}

add_node <- function(clean = FALSE) {
  if (clean && fs::dir_exists(node_path())) {
    fs::dir_delete(node_path())
  }

  copy_template("node", node_path())
  withr::with_dir(node_path(), {
    if (is_windows()) link_root_mklink()
    else link_root_fs()
  })
}

npm <- function(...) {
  check_system_dependency(
    cmd = "node",
    dependency_name = "Node.js",
    documentation_url = "https://go.appsilon.com/rhino-system-dependencies"
  )
  if (!fs::dir_exists(node_path())) {
    add_node()
    system_npm("install", "--no-audit", "--no-fund")
  }
  system_npm(...)
}
