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
    
    xpath_public <- make_r6_components_xpath("public")
    xpath_active <- make_r6_components_xpath("active")
    xpath_private <- make_r6_components_xpath("private")
    
    xpath_self_calls <- make_r6_internal_calls_xpath("self")
    xpath_private_calls <- make_r6_internal_calls_xpath("private")
    
    public_components <- xml2::xml_find_all(r6_class, xpath_public)
    active_components <- xml2::xml_find_all(r6_class, xpath_active)
    private_components <- xml2::xml_find_all(r6_class, xpath_private)
    
    self_method_calls <- xml2::xml_find_all(r6_class, xpath_self_calls)
    private_method_calls <- xml2::xml_find_all(r6_class, xpath_private_calls)
    
    public_components_text <- unlist(
      lapply(public_components, function(component) {
        component_name <- lintr::get_r_string(component)
        
        paste(
          "self",
          component_name,
          sep = "$"
        )
      })
    )
    
    active_components_text <- unlist(
      lapply(active_components, function(component) {
        component_name <- lintr::get_r_string(component)
        
        paste(
          "self",
          component_name,
          sep = "$"
        )
      })
    )
    
    private_components_text <- unlist(
      lapply(private_components, function(component) {
        component_name <- lintr::get_r_string(component)
        
        paste(
          "private",
          component_name,
          sep = "$"
        )
      })
    )
    
    components_text <- c(public_components_text, active_components_text, private_components_text)
    all_internal_calls <- c(self_method_calls, private_method_calls)
    all_internal_calls_names <- c(
      lintr::get_r_string(self_method_calls),
      lintr::get_r_string(private_method_calls)
    )
    
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
    
    unused_private <- lapply(private_components, function(component) {
      component_name <- paste(
        "private",
        lintr::get_r_string(component),
        sep = "$"
      )
      
      if (!component_name %in% all_internal_calls_names) {
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

