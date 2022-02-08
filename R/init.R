rprofile_init <- function() {
  options(box.path = c(
    fs::path_wd("app"), # Allow absolute module imports (relative to the app root).
    fs::path_package("rhino", "box_modules")
  ))

  log_level <- Sys.getenv("RHINO_LOG_LEVEL", unset = "INFO")
  log_file <- Sys.getenv("RHINO_LOG_FILE", unset = NA)
  logger::log_threshold(log_level)
  if (!is.na(log_file)) {
    logger::log_appender(logger::appender_file(log_file))
  }
}
