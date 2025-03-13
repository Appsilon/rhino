min_css_path <- fs::path("app", "static", "css", "app.min.css")
main_css_path <- fs::path("app", "styles", "main.scss")

# Create minimal css and check app.min.css output
cat(
  ".myClass { color: #fff; }\n",
  file = main_css_path
)
rhino::build_sass()
testthat::expect_identical(
  readLines(min_css_path),
  ".myClass{color:#fff}"
)

# Revert to empty CSS and check output
cat("\n", file = main_css_path
)
rhino::build_sass()
testthat::expect_identical(
  readLines(min_css_path), ""
)
