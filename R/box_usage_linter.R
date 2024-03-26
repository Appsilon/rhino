#' @export
box_usage_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_functions <- get_attached_functions(xml)
    attached_three_dots <- get_attached_three_dots(xml)
    all_attached_fun <- c(attached_functions$text, attached_three_dots$text)

    fun_assignments <- get_declared_functions(xml)
    all_known_fun <- c(all_attached_fun, fun_assignments$text)

    attached_packages <- get_attached_packages(xml)
    function_calls <- get_function_calls(xml)
    base_pkgs <- get_base_packages()

    lapply(function_calls$xml_nodes, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)

      if (!fun_call_text %in% base_pkgs$text) {
        if (grepl(".+\\$.+", fun_call_text)) {
          if (!fun_call_text %in% attached_packages$text) {
            lintr::xml_nodes_to_lints(
              fun_call,
              source_expression = source_expression,
              lint_message = "package$function does not exist.",
              type = "warning"
            )
          }
        } else {
          if (!fun_call_text %in% all_known_fun) {
            lintr::xml_nodes_to_lints(
              fun_call,
              source_expression = source_expression,
              lint_message = "Function not imported.",
              type = "warning"
            )
          }
        }
      }
    })
  })
}

get_packages_exports <- function(pkg_list) {
  exported_funs <- lapply(pkg_list, function(pkg) {
    tryCatch(
      getNamespaceExports(pkg),
      error = function(e) character()
    )
  })

  names(exported_funs) <- pkg_list

  exported_funs
}

get_base_packages <- function() {
  base_pkgs_names <- utils::sessionInfo()$basePkgs
  base_pkgs_funs <- get_packages_exports(base_pkgs_names)
  base_pkgs_funs_flat <- unlist(base_pkgs_funs, use.names = FALSE)

  list(
    nested = base_pkgs_funs,
    text = base_pkgs_funs_flat
  )
}
