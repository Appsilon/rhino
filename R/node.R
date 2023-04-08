node_path <- function(...) {
  fs::path(".rhino", ...)
}

add_node <- function(clean = FALSE) {
  if (clean) {
    fs::dir_delete(node_path(), recursive = TRUE)
  }
  copy_template("node", node_path())
}

# Run `npm` command (assume node directory already exists in the project).
npm_raw <- function(commands, status_ok = 0) {
  withr::with_dir(node_path(), {
    status <- system2(command = "npm", args = commands)
  })
  if (status != status_ok) {
    cli::cli_abort("System command 'npm' exited with status {status}.")
  }
}

# Run `npm` command (create node directory in the project if needed).
npm <- function(...) {
  check_system_dependency(
    cmd = "node",
    dependency_name = "Node.js",
    documentation_url = "https://go.appsilon.com/rhino-system-dependencies"
  )
  # Check if node directory exists, create it otherwise and install dependencies
  if (!fs::dir_exists(node_path())) {
    add_node()
    npm_raw("install", "--no-audit")
  }
  # Run npm commands with specified arguments
  npm_raw(list(...))
}
