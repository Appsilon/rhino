# Verifies `build_sass()` exercises the dart-sass feature surface, not just trivial
# compilation: a partial loaded via `@use`, a variable, a `@mixin`/`@include`, rule
# nesting, and a math expression. These are exactly what a `sass` major bump tends to
# break (e.g. dropping `@import`/`@use` support or changing the math/color modules).

min_css_path <- fs::path("app", "static", "css", "app.min.css")
main_scss_path <- fs::path("app", "styles", "main.scss")
vars_scss_path <- fs::path("app", "styles", "_vars.scss")

cat("$primary: #0099f9;\n", file = vars_scss_path)
cat(
  paste0(
    "@use 'vars';\n\n",
    "@mixin padded($x) {\n",
    "  padding: $x;\n",
    "}\n\n",
    ".box {\n",
    "  color: vars.$primary;\n",
    "  @include padded(10px);\n\n",
    "  .inner {\n",
    "    width: 2px * 3;\n",
    "  }\n",
    "}\n"
  ),
  file = main_scss_path
)
rhino::build_sass()
testthat::expect_identical(
  readLines(min_css_path),
  ".box{color:#0099f9;padding:10px}.box .inner{width:6px}"
)

# Clean up the partial; revert main.scss to empty and check the (empty) output.
file.remove(vars_scss_path)
cat("\n", file = main_scss_path)
rhino::build_sass()
testthat::expect_identical(
  readLines(min_css_path), ""
)
