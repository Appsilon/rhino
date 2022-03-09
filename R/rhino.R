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

rproj_exists <- function() {
  length(fs::dir_ls(type = "file", glob = "*.Rproj")) > 0
}

copy_rproj <- function() {
  file_name <- paste0(
    basename(fs::path_abs(".")),
    ".Rproj"
  )

  fs::file_copy(
    fs::path_package("rhino", "templates", "rproj", "Rproj.template"),
    fs::path(".", file_name)
  )
}
