describe("configure_logger()", {
  it("works with missing config fields", {
    mockery::stub(configure_logger, "config::get", list())
    expect_message(configure_logger())

    mockery::stub(configure_logger, "config::get", list(rhino_log_level = "INFO"))
    expect_message(configure_logger())

    mockery::stub(configure_logger, "config::get", list(rhino_log_file = "my.log"))
    expect_message(configure_logger())

    mockery::stub(
      configure_logger,
      "config::get",
      list(rhino_log_level = "INFO", rhino_log_file = "my.log")
    )
    expect_silent(configure_logger())
  })
})

describe("normalize_main()", {
  it("handles a Shiny module", {
    main <- list(
      ui = function(id) shiny::tags$div("test"),
      server = function(id) {
        shiny::moduleServer(id, function(input, output, session) {})
      }
    )
    wrapped <- normalize_main(main, is_module = TRUE)
    expect_identical(names(formals(wrapped$ui)), c("request"))
    expect_identical(names(formals(wrapped$server)), c("input", "output", "session"))
  })
})

describe("normalize_ui()", {
  it("handles UI defined as a Shiny module", {
    ui <- function(id) shiny::tags$div("test")
    wrapped <- normalize_ui(ui, is_module = TRUE)
    expect_identical(wrapped("request"), ui("app"))
  })

  it("handles UI defined as a tag", {
    ui <- shiny::tags$div("test")
    wrapped <- normalize_ui(ui)
    expect_identical(wrapped("request"), ui)
  })

  it("handles UI defined as a function without parameters", {
    ui <- function() shiny::tags$div("test")
    wrapped <- normalize_ui(ui)
    expect_identical(wrapped("request"), ui())
  })

  it("handles UI defined as a function with a request parameter", {
    ui <- function(request) shiny::tags$div(request)
    wrapped <- normalize_ui(ui)
    expect_identical(wrapped("request"), ui("request"))
  })
})

describe("normalize_server()", {
  it("handles server defined as a Shiny module", {
    server <- function(id) {
      shiny::moduleServer(id, function(input, output, session) {})
    }
    wrapped <- normalize_server(server, is_module = TRUE)
    expect_identical(names(formals(wrapped)), c("input", "output", "session"))
  })

  it("handles server wihout session paramter", {
    server <- function(input, output) {}
    wrapped <- normalize_server(server)
    expect_identical(names(formals(wrapped)), c("input", "output", "session"))
  })

  it("handles server with session parameter", {
    server <- function(input, output, session) {}
    wrapped <- normalize_server(server)
    expect_identical(names(formals(wrapped)), c("input", "output", "session"))
  })
})

describe("with_head_tags()", {
  it("attaches a head tag to UI", {
    ui <- function(request) shiny::tags$div("test")
    wrapped <- with_head_tags(ui)
    first_tag <- wrapped("request")[[1]]$name
    expect_identical(first_tag, "head")
  })
})

describe("reparse()", {
  it("ensures a function has source reference information attached", {
    f <- eval(
      expr = parse(text = "function() 1", keep.source = FALSE),
      envir = new.env(parent = baseenv())
    )
    g <- reparse(f)

    expect_identical(f, g)
    expect_false("srcref" %in% names(attributes(f)))
    expect_true("srcref" %in% names(attributes(g)))
  })
})
