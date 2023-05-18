rhino::build_sass()

min_css_path <- fs::path("app", "static", "css", "app.min.css")
main_css_path <- fs::path("app", "styles", "main.scss")

testthat::expect_equal(
  readLines(min_css_path), ""
)

# Create minimal css and check app.min.css output
cat(
  ".myClass { color: #fff; }\n",
  file = main_css_path,
  append = TRUE
)
rhino::build_sass()
testthat::expect_equal(
  readLines(min_css_path),
  ".myClass{color:#fff}"
)
# Clean up
cat(
  "",
  file = main_css_path
)
cat(
  "",
  file = min_css_path
)
