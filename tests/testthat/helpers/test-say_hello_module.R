box::use(testthat[describe, expect_identical, it], )

box::use(app/logic/say_hello_module, )

describe("say_hello$say_hello()", {
  it("should say hello with the correct name", {
    expect_identical(say_hello_module$say_hello("Rhino"), "Hello, Rhino!")
  })
})

# Private box module function testing according to
# https://klmr.me/box/articles/testing.html#test-interfaces-not-implementation-details
# Second implementation.

impl <- attr(say_hello_module, "namespace")

describe("say_hello private function private_hello()", {
  it("should say hello with the correct name", {
    expect_identical(impl$private_hello("Rhino"), "Hello, Rhino!")
  })
})
