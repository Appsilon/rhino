box::use(testthat[describe, expect_identical, it], )
box::use(app/logic/hello[hello], )

describe("hello()", {
  it("should return the welcome message", {
    expect_identical(hello(), "Check out Rhino docs!")
  })
})