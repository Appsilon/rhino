#' Run unit tests
#'
#' @importFrom testthat test_dir
#' @export
test_r <- function() {
  test_dir("tests/testthat")
}
