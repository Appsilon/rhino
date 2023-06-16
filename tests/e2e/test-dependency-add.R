rhino::dependency_add("dplyr")

# is package installed and working?
testthat::expect_equal(
  mtcars[mtcars$cyl > 6, ],
  dplyr::filter(mtcars, cyl > 6)
)

# is package present in dependencies.R?
# tbd

# is package present in renv.lock?
# tbd

# Clean up proposition - this is obvious, but risky (since not tested)
# rhino::dependency_remove("dplyr")
