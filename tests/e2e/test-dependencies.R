# Check if package is installed without loading or attaching it.
is_installed <- function(package) {
  length(find.package(package, quiet = TRUE)) > 0
}

initial_dependencies <- readLines("dependencies.R")
initial_lockfile <- readLines("renv.lock")

# Check initial state.
testthat::expect_false(is_installed("dplyr"))
testthat::expect_false(any(initial_dependencies == "library(dplyr)"))
testthat::expect_false(any(initial_lockfile == '    "dplyr": {'))

# Install package and check if it was done correctly.
rhino::pkg_install("dplyr")
testthat::expect_true(is_installed("dplyr"))
testthat::expect_setequal(
  readLines("dependencies.R"),
  c(initial_dependencies, "library(dplyr)")
)
testthat::expect_contains(
  readLines("renv.lock"),
  '    "dplyr": {'
)

# Remove package and check if we're back to initial state.
rhino::pkg_remove("dplyr")
testthat::expect_false(is_installed("dplyr"))
testthat::expect_identical(readLines("dependencies.R"), initial_dependencies)
testthat::expect_identical(readLines("renv.lock"), initial_lockfile)

# install package from GitHub

initial_dependencies <- readLines("dependencies.R")
initial_lockfile <- readLines("renv.lock")

# Check initial state.
testthat::expect_false(is_installed("shiny.i18n"))
testthat::expect_false(any(initial_dependencies == "library(shiny.i18n)"))
testthat::expect_false(any(initial_lockfile == '    "shiny.i18n": {'))

# Install package and check if it was done correctly.
rhino::pkg_install("Appsilon/shiny.i18n")
testthat::expect_true(is_installed("shiny.i18n"))
testthat::expect_setequal(
  readLines("dependencies.R"),
  c(initial_dependencies, "library(shiny.i18n)")
)
testthat::expect_contains(
  readLines("renv.lock"),
  '    "shiny.i18n": {'
)

# Remove package and check if we're back to initial state.
rhino::pkg_remove("shiny.i18n")
testthat::expect_false(is_installed("shiny.i18n"))
testthat::expect_identical(readLines("dependencies.R"), initial_dependencies)
testthat::expect_identical(readLines("renv.lock"), initial_lockfile)


# install package from Bioconductor

initial_dependencies <- readLines("dependencies.R")
initial_lockfile <- readLines("renv.lock")

# Check initial state.
testthat::expect_false(is_installed("Biobase"))
testthat::expect_false(any(initial_dependencies == "library(Biobase)"))
testthat::expect_false(any(initial_lockfile == '    "Biobase": {'))

# Install package and check if it was done correctly.
rhino::pkg_install("bioc::Biobase")
testthat::expect_true(is_installed("Biobase"))
testthat::expect_setequal(
  readLines("dependencies.R"),
  c(initial_dependencies, "library(Biobase)")
)
testthat::expect_contains(
  readLines("renv.lock"),
  '    "Biobase": {'
)

# Remove package and check if we're back to initial state.
rhino::pkg_remove("Biobase")
testthat::expect_false(is_installed("Biobase"))
testthat::expect_identical(readLines("dependencies.R"), initial_dependencies)
testthat::expect_identical(readLines("renv.lock"), initial_lockfile)
