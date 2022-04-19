#' Logging functions
#'
#' Convenient way to log messages at a desired severity level.
#'
#' The `log` object is a list of logging functions, in order of decreasing severity:
#' 1. `fatal`
#' 2. `error`
#' 3. `warn`
#' 4. `success`
#' 5. `info`
#' 6. `debug`
#' 7. `trace`
#'
#' Rhino configures logging based on settings read from the `config.yml` file
#' in the root of your project:
#' 1. `rhino_log_level`: The minimum severity of messages to be logged.
#' 2. `rhino_log_file`: The file to save logs to. If `NA`, standard error stream will be used.
#'
#' The default `config.yml` file uses `!expr Sys.getenv()`
#' so that log level and file can also be configured
#' by setting the `RHINO_LOG_LEVEL` and `RHINO_LOG_FILE` environment variables.
#'
#' The functions re-exported by the `log` object are aliases for `{logger}` functions.
#' You can also import the package and use it directly to utilize its full capabilities.
#'
#' @examples
#' \dontrun{
#'   box::use(rhino[log])
#'
#'   # Messages can be formatted using glue syntax.
#'   name <- "Rhino"
#'   log$warn("Hello {name}!")
#'   log$info("{1:3} + {1:3} = {2 * (1:3)}")
#' }
#' @export
log <- list(
  fatal = logger::log_fatal,
  error = logger::log_error,
  warn = logger::log_warn,
  success = logger::log_success,
  info = logger::log_info,
  debug = logger::log_debug,
  trace = logger::log_trace
)
