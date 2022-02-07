#' @export
lint_r <- function() {
  config <- yaml::read_yaml(".lintr.yaml", eval.expr = TRUE)
  linters <- do.call(lintr::with_defaults, config$linters)

  lints <- c(
    lapply(config$files, lintr::lint, linters = linters),
    lapply(config$directories, lintr::lint_dir, linters = linters)
  )
  lints <- structure(do.call(c, lints), class = "lints") # Flatten and restore class

  for (lint in lints) {
    print(lint)
  }

  return(length(lints) == 0)
}

#' @export
format_r <- function() styler::style_dir("app/r")
