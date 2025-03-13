describe("%<-% - argument validation", {
  it("throws an error when the LHS isn't a call", {
    expect_error(asdf %<-% list(a = 123, b = 456))
  })

  it("throws an error when the LHS isn't a c() call", {
    expect_error(x() %<-% list(a = 123, b = 456))
  })

  it("throws an error when the LHS is a c() call, but contains ellipsis", {
    expect_error(c(...) %<-% list(a = 123, b = 456))
    expect_error(c(a, ...) %<-% list(a = 123, b = 456))
  })

  it("throws an error when the RHS is something else than a list", {
    expect_error(c(a, b) %<-% asdf())
    expect_error(c(a, b) %<-% function() {})
    expect_error(c(a, b) %<-% c(1, 2))
    expect_error(c(a, b) %<-% new.env())
  })

  it("throws an error when the RHS is a data.frame", {
    expect_error(c(a, b) %<-% data.frame())
  })

  it("throws an error when the RHS is a list, but an unnamed one", {
    expect_error(c(a, b) %<-% list(1, 2))
  })
})

describe("%<-% - destructuring", {
  it("destructures a list with 1 element by name", {
    # Arrange
    rhs <- list(x = 123)

    # Act
    c(x) %<-% rhs

    # Assert
    expect_equal(x, 123)
  })

  it("assigns values of a list with unsorted names by names", {
    # Arrange
    rhs <- list(z = 789, x = 123, y = 456)

    # Act
    c(x, y, z) %<-% rhs

    # Assert
    expect_equal(x, 123)
    expect_equal(y, 456)
    expect_equal(z, 789)
  })

  it("assigns only to the values present on the the LHS", {
    # Arrange
    rhs <- list(z = 789, x = 123, y = 456)

    # Act
    c(x, z) %<-% rhs

    # Assert
    expect_equal(x, 123)
    expect_error(y)
    expect_equal(z, 789)
  })

  it("throws an error when the LHS has a name not present on the RHS", {
    expect_error(c(a) %<-% list(x = 123, y = 456))
  })

  it("handles the native pipe operator (|>) when the RHS expression is wrapped in brackets", {
    # Act
    c(y) %<-% (
      123 |>
        list(x = 123, y = _)
    )

    # Assert
    expect_equal(y, 123)
  })

  it("works with functions that return a list", {
    # Arrange
    get_person <- function() {
      list(
        name = "John Doe",
        age = 30,
        email = "john@example.com"
      )
    }

    # Act
    c(name, age) %<-% get_person()

    # Assert
    expect_equal(name, "John Doe")
    expect_equal(age, 30)
  })

  it("fails when destructuring non-existent names from a function return value", {
    # Arrange
    get_person <- function() {
      list(
        name = "John Doe",
        age = 30
      )
    }

    # Assert
    expect_error(c(name, phone) %<-% get_person())
  })
})
