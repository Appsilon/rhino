#' @export
r6_usage_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content

    xpath_r6_class <- "
    //expr[
      expr[1]/SYMBOL_FUNCTION_CALL[text() = 'R6Class']
    ]"

    r6_class <- xml2::xml_find_all(xml, xpath_r6_class)

    if (length(r6_class) == 0) {
      return(list())
    }

    public_components <- get_r6_components(r6_class, "public")
    active_components <- get_r6_components(r6_class, "active")
    private_components <- get_r6_components(r6_class, "private")

    components_text <- c(public_components$text, active_components$text, private_components$text)

    xpath_self_calls <- make_r6_internal_calls_xpath("self")
    xpath_private_calls <- make_r6_internal_calls_xpath("private")

    self_method_calls <- extract_xml_and_text(r6_class, xpath_self_calls)
    private_method_calls <- extract_xml_and_text(r6_class, xpath_private_calls)

    all_internal_calls <- c(self_method_calls$xml, private_method_calls$xml)
    all_internal_call_names <- c(self_method_calls$text, private_method_calls$text)

    invalid_object <- lapply(all_internal_calls, function(internal_call) {
      call_name <- lintr::get_r_string(internal_call)

      if (!call_name %in% components_text) {
        lintr::xml_nodes_to_lints(
          internal_call,
          source_expression = source_expression,
          lint_message = "Internal object call not found.",
          type = "warning"
        )
      }
    })

    unused_private <- lapply(private_components$xml, function(component) {
      component_name <- paste(
        "private",
        lintr::get_r_string(component),
        sep = "$"
      )

      if (!component_name %in% all_internal_call_names) {
        lintr::xml_nodes_to_lints(
          component,
          source_expression = source_expression,
          lint_message = "Private object not used.",
          type = "warning"
        )
      }
    })

    c(
      invalid_object,
      unused_private
    )
  })
}

make_r6_components_xpath <- function(mode = c("public", "active", "private")) {
  glue::glue("
    //SYMBOL_SUB[text() = '{mode}']
    /following-sibling::EQ_SUB[1]
    /following-sibling::expr[1]
    /child::SYMBOL_SUB
  ")
}

make_r6_internal_calls_xpath <- function(mode = c("self", "private")) {
  glue::glue("
    //expr[
      ./expr/SYMBOL[text() = '{mode}'] and
      ./OP-DOLLAR and
      (
        ./SYMBOL_FUNCTION_CALL or
        ./SYMBOL
      )
    ]
  ")
}

get_r6_components <- function(xml, mode = c("public", "active", "private")) {
  xpath <- make_r6_components_xpath(mode)
  components <- xml2::xml_find_all(xml, xpath)

  base_prefix <- list(
    "public" = "self",
    "active" = "self",
    "private" = "private"
  )

  components_text <- unlist(
    lapply(components, function(component) {
      component_name <- lintr::get_r_string(component)

      paste(
        base_prefix[[mode]],
        component_name,
        sep = "$"
      )
    })
  )

  list(
    xml = components,
    text = components_text
  )
}
