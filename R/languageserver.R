#' Add `{languageserver}`` parsers for `{box}`
#'
#' @return None. This function is called for its side effects.
#'
#' @export
box_use_parser <- function(expr, action) {
  call <- match.call(box::use, expr)
  packages <- unlist(lapply(call[-1], function(x) {
    # this is for the last blank in box::use(something, )
    if (x == "") {
      return()
    }

    # this is for a whole package attached box::use(dplyr)
    if (typeof(x) == "symbol") {
      return(as.character(x))
    }

    # this is for a whole module attached box::use(app/logic/utils)
    if (as.character(x[[1]]) == "/") {
      y <- x[[length(x)]]

      # this case is for app/logic/module_one
      if (length(y) == 1) {
        action$assign(symbol = as.character(y), value = NULL)
      }

      # this case is for app/logic/module_two[...]
      if (length(y) == 3 && y[[3]] == "...") {
        # import box module, iterate over its namespace and assign
      }

      # this case is for app/logic/module_three[a, b, c]
      lapply(y[-c(1, 2)], function(z) {
        action$assign(symbol = as.character(z), value = NULL)
      })

      return()
    }

    # this is for package three dots attached box::use(dplyr[filter, ...])
    as.character(x[[2]])
  }))

  action$update(packages = packages)
}
