#' Destructure a named list into individual variables
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The destructuring operator `%<-%` allows you to extract multiple named values from a list
#' into individual variables in a single assignment. This provides a convenient way to
#' unpack list elements by name.
#'
#' While it works with any named list, it was primarily designed to improve the ergonomics
#' of working with Shiny modules that return multiple reactive values. Instead of manually
#' assigning each reactive value from a module's return list, you can destructure them all
#' at once.
#'
#' @param lhs A call to `c()` containing variable names to assign to. All variable names should
#'   exist in the rhs list.
#' @param rhs A named list containing the values to assign
#'
#' @return Invisibly returns the right-hand side list
#'
#' @examples
#' # Basic destructuring
#' data <- list(x = 1, y = 2, z = 3)
#' c(x, y) %<-% data
#' x  # 1
#' y  # 2
#'
#' # Works with unsorted names
#' result <- list(last = "Smith", first = "John")
#' c(first, last) %<-% result
#'
#' # Shiny module example
#' if (interactive()) {
#'   module_server <- function(id) {
#'     shiny::moduleServer(id, function(input, output, session) {
#'       list(
#'         value = shiny::reactive(input$num),
#'         text = shiny::reactive(input$txt)
#'       )
#'     })
#'   }
#'
#'   # Clean extraction of reactive values
#'   c(value, text) %<-% module_server("my_module")
#' }
#'
#' # Can be used with pipe operations
#' # Note: The piped expression must be wrapped in brackets
#' \dontrun{
#' c(value) %<-% (
#'   123 |>
#'     list(value = _)
#' )
#' }
#' @export
`%<-%` <- function(lhs, rhs) {
  # LHS validation
  lhs <- substitute(lhs)
  if (!is.call(lhs)) {
    stop("%<-% : only calls are allowed on the left-hand side")
  }

  if (lhs[[1]] != as.name("c")) {
    stop("%<-% : invalid call on the left-hand side - only c() is allowed")
  }

  # RHS validation
  if (!is.list(rhs)) {
    stop("%<-% : only lists are allowed on the right-hand side")
  }

  if (is.data.frame(rhs)) {
    stop("%<-% : data.frames are not supported on the right-hand side")
  }

  if (is.null(names(rhs))) {
    stop("%<-% : only *named* lists are supported on the right-hand side")
  }

  lhs_names <- as.list(lhs)[-1]
  for (name in lhs_names) {
    name <- as.character(name)
    if (name == "...") {
      stop("%<-% : ... is not supported on the left-hand side")
    }

    value <- rhs[[name]]
    if (is.null(value)) {
      stop(paste0("%<-% : couldn't find the '", name, "' key in the list on the right-hand side"))
    }

    assign(name, value, envir = parent.frame())
  }

  invisible(rhs)
}
