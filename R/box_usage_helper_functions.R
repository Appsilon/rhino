box_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  "
}

extract_xml_and_text <- function(xml, xpath) {
  xml_nodes <- xml2::xml_find_all(xml, xpath)
  text <- lintr::get_r_string(xml_nodes)
  text <- gsub("[`'\"]", "", text)

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

get_attached_functions <- function(xml, xpath) {
  xpath_just_functions <- "
  /child::expr[
    expr/SYMBOL and
    OP-LEFT-BRACKET and
    not(
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        SYMBOL[
          text() = '...'
        ]
      ]
    )
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

  xpath_attached_functions <- paste(box_base_path(), xpath_just_functions)
  attached_functions <- extract_xml_and_text(xml, xpath_attached_functions)

  list(
    xml = attached_functions$xml_nodes,
    text = attached_functions$text
  )
}

get_declared_functions <- function(xml) {
  xpath_function_assignment <- "
  //expr[
      (LEFT_ASSIGN or EQ_ASSIGN) and ./expr[2][FUNCTION or OP-LAMBDDA]
    ]
    /expr[1]/SYMBOL
  | //expr_or_assign_or_help[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //equal_assign[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //SYMBOL_FUNCTION_CALL[text() = 'assign']/parent::expr[
      ./following-sibling::expr[2][FUNCTION or OP-LAMBDA]
    ]
    /following-sibling::expr[1]/STR_CONST
  "

  extract_xml_and_text(xml, xpath_function_assignment)
}

get_function_calls <- function(xml) {
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

  # lintr::get_r_string throws an error when seeing SYMBOL %>%
  xml_nodes <- xml2::xml_find_all(xml, xpath_box_function_calls)
  text <- xml2::xml_text(xml_nodes, trim = TRUE)
  r6_refs <- internal_r6_refs(text)

  xml_nodes <- xml_nodes[!r6_refs]
  text <- text[!r6_refs]

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

internal_r6_refs <- function(func_list) {
  r6_refs <- "self|private\\$.+"
  grepl(r6_refs, func_list)
}
