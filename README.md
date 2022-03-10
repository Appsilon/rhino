# Rhino

<!-- badges: start -->
[![R build status](https://github.com/Appsilon/rhino/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/rhino/actions)
<!-- badges: end -->

### Development Tools
#### Unit Tests
Unit tests can be run using `devtools::test()`.

Alternatively, the package can be installed, and then tested with `testthat::test_package("rhino")`.

#### Linter
Linter can be run using either `lintr::lint_package()` or `devtools::lint()`.

#### `pkgdown` site
To create a `pkgdown` site locally run either `pkgdown::build_site()` or `devtools::build_site()`.
If built successfully, the website will be in `docs` directory.
