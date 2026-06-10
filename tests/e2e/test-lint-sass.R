# Verifies `lint_sass()` enforces both the stylelint-config-standard-scss ruleset and
# Rhino's custom rules from `.stylelintrc.json`, and that `fix = TRUE` auto-fixes.
# A dependency bump could drop the scss rules or the custom selector pattern - guarded below.

# The default scaffolded app lints clean.
rhino::lint_sass()

bad_id_path <- fs::path("app", "styles", "bad-id.scss")
bad_scss_path <- fs::path("app", "styles", "bad-scss.scss")
test_scss_path <- fs::path("app", "styles", "bad-style.scss")

# `finally` removes the fixtures even if an expectation fails, so a failure here does not
# leave bad `.scss` files behind for the later `if: always()` workflow steps.
tryCatch(
  {
    # Rhino's custom `selector-id-pattern` (kebab-snake_case) is enforced.
    cat("#CamelCase {\n  color: red;\n}\n", file = bad_id_path)
    testthat::expect_error(rhino::lint_sass())
    file.remove(bad_id_path)

    # An scss-namespaced rule from stylelint-config-standard-scss is enforced.
    # The camelCase variable name violates scss/dollar-variable-pattern.
    cat("$myVar: 10px;\n\n.a {\n  width: $myVar;\n}\n", file = bad_scss_path)
    testthat::expect_error(rhino::lint_sass())
    file.remove(bad_scss_path)

    # `fix = TRUE` auto-fixes style violations (hex case + spacing).
    cat(".my-class{color: #FFFFFF}", file = test_scss_path)
    testthat::expect_error(rhino::lint_sass())
    rhino::lint_sass(fix = TRUE)
    testthat::expect_identical(
      readLines(test_scss_path),
      ".my-class { color: #fff; }"
    )
  },
  finally = unlink(c(bad_id_path, bad_scss_path, test_scss_path))
)
