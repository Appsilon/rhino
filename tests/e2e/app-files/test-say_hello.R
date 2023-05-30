box::use(testthat[...])

box::use(app/logic/say_hello[say_hello])

describe("say_hello()", {
  it("should say hello with the correct name", {
    expect_identical(say_hello("Rhino"), "Hello, Rhino!")
  })
})
