# Verifies `lint_sass()` enforces both the stylelint-config-standard-scss ruleset and
# Rhino's custom rules from `.stylelintrc.json`, and that `fix = TRUE` auto-fixes.
# A dependency bump could drop the scss rules or the custom selector pattern - guarded below.

# The default scaffolded app lints clean.
rhino::lint_sass()

# Rhino's custom `selector-id-pattern` (kebab-snake_case) is enforced.
bad_id_path <- fs::path("app", "styles", "bad-id.scss")
cat("#CamelCase {\n  color: red;\n}\n", file = bad_id_path)
testthat::expect_error(rhino::lint_sass())
file.remove(bad_id_path)

# An scss-namespaced rule from stylelint-config-standard-scss is enforced.
# The camelCase variable name violates scss/dollar-variable-pattern.
bad_scss_path <- fs::path("app", "styles", "bad-scss.scss")
cat("$myVar: 10px;\n\n.a {\n  width: $myVar;\n}\n", file = bad_scss_path)
testthat::expect_error(rhino::lint_sass())
file.remove(bad_scss_path)

# `fix = TRUE` auto-fixes style violations (hex case + spacing).
test_scss_path <- fs::path("app", "styles", "bad-style.scss")
cat(".my-class{color: #FFFFFF}", file = test_scss_path)
testthat::expect_error(rhino::lint_sass())
rhino::lint_sass(fix = TRUE)
testthat::expect_identical(
  readLines(test_scss_path),
  ".my-class { color: #fff; }"
)
# Clean up
file.remove(test_scss_path)
