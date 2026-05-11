describe("extract_package_name", {
  it("returns the package name intact when using only the package name", {
    expect_equal(extract_package_name("shiny"), "shiny")
  })

  it("returns the package name intact when using the package name and version", {
    expect_equal(extract_package_name("shiny@1.6.0"), "shiny")
  })

  it("returns the package name when installing a package from GitHub", {
    expect_equal(extract_package_name("r-lib/httr"), "httr")
    expect_equal(extract_package_name("r-lib/testthat@c67018fa4970"), "testthat")
  })

  it("returns the package name when installing a package from a local path", {
    expect_equal(extract_package_name("~/path/to/package"), "package")
  })

  it("returns the package name when installing a package from Bioconductor", {
    expect_equal(extract_package_name("bioc::Biobase"), "Biobase")
  })
})

describe("extract_packages_names", {
  it("returns a vector of package names when installing multiple packages", {
    expect_equal(extract_packages_names(c("shiny", "dplyr")), c("shiny", "dplyr"))
  })
})

describe("pkg_install", {
  it("throws an error when the argument is not a character vector", {
    expect_error(pkg_install(1))
  })
})

describe("pkg_remove", {
  it("throws an error when the argument is not a character vector", {
    expect_error(pkg_remove(1))
  })
})
