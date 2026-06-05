#' @export
say_hello <- function(name) {
  private_hello(name)
}

private_hello <- function(name) {
  paste0("Hello, ", name, "!")
}
