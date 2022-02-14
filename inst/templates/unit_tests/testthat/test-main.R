box::use(
  shiny[testServer],
  testthat[...],
)
box::use(
  r/main[...],
)

test_that("main server works", {
  testServer(server, {
    expect_equal(output$message, "Hello!")
  })
})
