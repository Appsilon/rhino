box::use(
  shiny[testServer],
  testthat[expect_true, test_that],
)
box::use(
  app/main[server, ui],
)

test_that("main server works", {
  testServer(server, {
    expect_true(grepl(x = output$message$html, pattern = "Check out Rhino docs!"))
  })
})
