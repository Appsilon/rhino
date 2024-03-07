#' @export
box_usage_linter <- function() {
  box_base_path <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  "
  
  box_package_functions <- "
  /child::expr[
    expr/SYMBOL and
    OP-LEFT-BRACKET
  ]
  /expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL[
    not(
      text() = '...'
    )
  ]
  "
  
  box_package_import <- "
  /child::expr[
    SYMBOL
  ]
  "
  
  box_package_three_dots <- "
  /child::expr[
    expr/SYMBOL[text() = '...']
  ]
  /expr[
    following-sibling::OP-LEFT-BRACKET
  ]
  /SYMBOL
  "
  
  xpath_package_functions <- paste(box_base_path, box_package_functions)
  xpath_package_import <- paste(box_base_path, box_package_import)
  xpath_package_three_dots <- paste(box_base_path, box_package_three_dots)
  
  xpath_box_function_calls <- "
  //expr[
    SYMBOL_FUNCTION_CALL[
      not(text() = 'use')
    ] and
    not(
      SYMBOL_PACKAGE[text() = 'box']
    )
  ] |
  //SPECIAL
  "
  
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }
    
    xml <- source_expression$full_xml_parsed_content
    
    attached_functions <- get_attached_functions(xml, xpath_package_functions)
    attached_three_dots <- get_attached_three_dots(xml, xpath_package_three_dots)
    
    all_attached_fun <- c(attached_functions$text, attached_three_dots$text)
    
    attached_packages <- get_attached_packages(xml, xpath_package_import)
    
    function_calls <- xml2::xml_find_all(xml, xpath_box_function_calls)
    function_calls_text <- xml2::xml_text(function_calls)
    
    # remove base function calls
    
    unimported_functions <- lapply(function_calls, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)
      
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
        if (!fun_call_text %in% all_attached_fun) {
          lintr::xml_nodes_to_lints(
            fun_call,
            source_expression = source_expression,
            lint_message = "Function not imported.",
            type = "warning"
          )
        }
      }
    })
    
    unused_function_imports <- lapply(attached_functions$xml, function(fun_import) {
      fun_import_text <- xml2::xml_text(fun_import)
      fun_import_text <- gsub("`", "", fun_import_text)
      
      if (!fun_import_text %in% function_calls_text) {
        lintr::xml_nodes_to_lints(
          fun_import,
          source_expression = source_expression,
          lint_message = "Imported function unused.",
          type = "warning"
        )
      }
    })
    
    c(
      unimported_functions,
      unused_function_imports
    )
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

extract_xml_and_text <- function(xml, xpath) {
  xml_nodes <- xml2::xml_find_all(xml, xpath)
  text <- lintr::get_r_string(xml_nodes)
  text <- gsub("`", "", text)
  
  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

get_attached_functions <- function(xml, xpath) {
  attached_functions <- extract_xml_and_text(xml, xpath)
  
  list(
    xml = attached_functions$xml_nodes,
    text = attached_functions$text
  )
}

get_attached_three_dots <- function(xml, xpath) {
  attached_three_dots <- extract_xml_and_text(xml, xpath)
  
  nested_list <- get_packages_exports(attached_three_dots$text)
  flat_list <- unlist(nested_list, use.names = FALSE)
  
  list(
    xml = attached_three_dots$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}

get_attached_packages <- function(xml, xpath) {
  attached_packages <- extract_xml_and_text(xml, xpath)
  
  nested_list <- get_packages_exports(attached_packages$text)
  
  flat_list <- unlist(
    lapply(names(nested_list), function(pkg) {
      paste(
        pkg,
        nested_list[[pkg]],
        sep = "$"
      )
    })
  )
  
  list(
    xml = nested_list$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}
