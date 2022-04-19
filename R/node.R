system_yarn <- function(..., status_ok = 0) {
  status <- system2(
    command = "yarn",
    args = c("--cwd", shQuote(node_path()), ...)
  )
  if (status != status_ok) {
    cli::cli_abort("System command 'yarn' exited with status {status}.")
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

yarn <- function(...) {
  check_js_dependencies()

  if (!fs::dir_exists(node_path())) {
    add_node()
    system_yarn("install")
  }
  system_yarn(...)
}

check_js_dependencies <- function() {
  documentation_url <- "https://go.appsilon.com/rhino-system-dependencies"

  check_system_dependency(
    cmd = "node",
    dependency_name = "Node.js",
    documentation_url = documentation_url
  )

  check_system_dependency(
    cmd = "yarn",
    dependency_name = "yarn",
    documentation_url = documentation_url
  )
}
