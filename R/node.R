system_yarn <- function(..., status_ok = 0) {
  status <- system2(
    command = "yarn",
    args = c("--cwd", shQuote(node_path()), ...)
  )
  if (status != status_ok) {
    cli::cli_abort("System command 'yarn' exited with status {status}.")
  }
}

add_node <- function() {
  copy_template("node", node_path())
  fs::link_create(
    path = fs::path("..", ".."),
    new_path = fs::path(node_path(), "root")
  )
}

yarn <- function(..., check_message = NULL) {
  check_js_dependencies(check_message)

  if (!fs::dir_exists(node_path())) {
    add_node()
    system_yarn("install")
  }
  system_yarn(...)
}

check_js_dependencies <- function(additional_message = NULL) {
  documentation_url <- "https://appsilon.github.io/rhino/articles/tutorial-create-your-first-rhino-app.html#dependencies" #nolint

  check_system_dependency(
    cmd = "node",
    dependency_name = "Node.js",
    documentation_url = documentation_url,
    additional_message = additional_message
  )

  check_system_dependency(
    cmd = "yarn",
    dependency_name = "yarn",
    documentation_url = documentation_url,
    additional_message = additional_message
  )
}
