read_addin <- function(...) {
  path <- fs::path_package("rhino", "rstudio", "addins", ...)
  readChar(path, file.info(path)$size)
}

addin_module <- function() {
  rstudioapi::insertText(read_addin("module.R"))
}
