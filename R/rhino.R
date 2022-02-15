read_config <- function() {
  yaml::read_yaml("rhino.yml")
}

template_path <- function(...) {
  fs::path_package("rhino", "templates", ...)
}

node_path <- function(...) {
  fs::path(".rhino", "node", ...)
}

rename_template_path <- function(path) {
  path <- fs::path_split(path)[[1]]
  path <- sub("^dot.", ".", path)
  path <- sub(".template$", "", path)
  fs::path_join(path)
}

copy_template <- function(src, dst) {
  src <- template_path(src)
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
