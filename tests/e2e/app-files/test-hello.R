box::use(
  shiny[testServer],
  testthat[...],
)
box::use(
  app/view/hello[server, ui],
)

describe("hello$server()", {
  it("should print the correct message", {
    testServer(server, {
      session$setInputs(name = "Rhino", say_hello = 1)
      expect_identical(output$message, "Hello, Rhino!")
    })
  })
})
