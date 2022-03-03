# Given a path without extension, read either `{path}.yml` or `{path}.yaml`.
read_yaml <- function(path) {
  yml <- paste0(path, ".yml")
  yaml <- paste0(path, ".yaml")
  if (fs::file_exists(yml)) {
    if (fs::file_exists(yaml)) {
      cli::cli_alert_warning("Both '{yml}' and '{yaml}' found; reading '{yml}'.")
    }
    yaml::read_yaml(yml)
  } else if (fs::file_exists(yaml)) {
    yaml::read_yaml(yaml)
  } else {
    cli::cli_abort("Neither '{yml}' nor '{yaml}' found.")
  }
}

read_config <- function() {
  read_yaml("rhino")
}

node_path <- function(...) {
  fs::path(".rhino", "node", ...)
}

rename_template_path <- function(path) {
  path <- fs::path_split(path)[[1]]
  path <- sub("^dot\\.", ".", path)
  path <- sub("\\.template$", "", path)
  fs::path_join(path)
}

# Copy template from source path (relative to `inst/templates`) to destination
# with some renaming applied to the names of files and directories:
# 1. Leading `dot.` is replaced with `.`.
# 2. Trailing `.template` is removed.
copy_template <- function(src, dst = ".") {
  src <- fs::path_package("rhino", "templates", src)
  target <- function(path) {
    path <- fs::path_rel(path, start = src)
    path <- rename_template_path(path)
    fs::path(dst, path)
  }

  fs::dir_create(dst)
  fs::dir_walk(
    path = src,
    recurse = TRUE,
    type = "directory",
    fun = function(dir) fs::dir_create(target(dir))
  )
  fs::dir_walk(
    path = src,
    recurse = TRUE,
    type = "file",
    fun = function(file) fs::file_copy(file, target(file))
  )
}
