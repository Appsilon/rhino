box::use(
  shiny[testServer],
  testthat[...],
)
box::use(
  app/main[...],
)

test_that("main server works", {
  testServer(server, {
    expect_true(grepl(x = output$message$html, pattern = "Check out Rhino docs!"))
  })
})
