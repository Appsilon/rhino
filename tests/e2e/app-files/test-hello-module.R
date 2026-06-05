box::use(testthat[describe, expect_identical, it], )

box::use(app/logic/say_hello, )

describe("say_hello$say_hello()", {
  it("should say hello with the correct name", {
    expect_identical(say_hello$say_hello("Rhino"), "Hello, Rhino!")
  })
})

# Private box module function testing according to
# https://klmr.me/box/articles/testing.html#test-interfaces-not-implementation-details
# Second implementation.

impl <- attr(say_hello, "namespace")

describe("say_hello private function private_bye()", {
  it("should say bye with the correct name", {
    expect_identical(impl$private_bye("Rhino"), "Bye, Rhino!")
  })
})
