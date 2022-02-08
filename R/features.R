read_config <- function() yaml::read_yaml("rhino.yml", eval.expr = FALSE)

features <- list(
  ci_github
)

check_sync <- function(sync) {
  rhino_config <- read_config()
  for (feature in features) {
    config <- rhino_config$features[[feature$key]]
    message(glue::glue("Checking {feature$name}... "), appendLF = FALSE)
    status <- feature$check(config)
    message(status)
    if (sync) {
      if (status == "Missing") {
        message(glue::glue("Adding {feature$name}"))
        feature$add()
      } else if (status == "Dangling") {
        message(glue::glue("Removing {feature$name}"))
        feature$remove()
      }
    }
  }
}

#' @export
check <- function() check_sync(sync = FALSE)

#' @export
sync <- function() check_sync(sync = TRUE)
