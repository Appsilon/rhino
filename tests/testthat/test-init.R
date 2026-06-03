test_that("use_agents_md() copies AGENTS.md to the working directory", {
  withr::with_tempdir({
    use_agents_md()

    expect_true(fs::file_exists("AGENTS.md"))
    contents <- readLines("AGENTS.md")
    expect_true(any(grepl("## Importing and exporting", contents, fixed = TRUE)))
  })
})

test_that("use_agents_md() errors when AGENTS.md already exists in a non-interactive session", {
  withr::with_tempdir({
    fs::file_create("AGENTS.md")
    expect_error(use_agents_md(), regexp = "already exists")
  })
})

test_that("use_github_actions_ci() copies the workflow to .github/workflows/", {
  withr::with_tempdir({
    use_github_actions_ci()

    workflow <- fs::path(".github", "workflows", "rhino-test.yml")
    expect_true(fs::file_exists(workflow))
    expect_true(any(grepl("Rhino Test", readLines(workflow), fixed = TRUE)))
  })
})

test_that("use_github_actions_ci() errors when the workflow exists in non-interactive mode", {
  withr::with_tempdir({
    fs::dir_create(fs::path(".github", "workflows"))
    fs::file_create(fs::path(".github", "workflows", "rhino-test.yml"))
    expect_error(use_github_actions_ci(), regexp = "already exist")
  })
})

test_that("use_e2e_tests() creates the Cypress structure", {
  withr::with_tempdir({
    use_e2e_tests()

    expect_true(fs::file_exists(fs::path("tests", "cypress.config.js")))
    expect_true(fs::file_exists(fs::path("tests", "cypress", "e2e", "app.cy.js")))
  })
})

test_that("use_e2e_tests() errors when the structure exists in non-interactive mode", {
  withr::with_tempdir({
    fs::dir_create(fs::path("tests", "cypress"))
    expect_error(use_e2e_tests(), regexp = "already exist")
  })
})

test_that("use_e2e_tests() backs up an existing structure and writes a fresh one", {
  withr::with_tempdir({
    fs::dir_create(fs::path("tests", "cypress", "e2e"))
    writeLines("old spec", fs::path("tests", "cypress", "e2e", "app.cy.js"))
    writeLines("old config", fs::path("tests", "cypress.config.js"))

    testthat::with_mocked_bindings(
      prompt_conflict = function(paths) 2L,
      use_e2e_tests()
    )

    # Old content preserved in the backups (directory moved aside wholesale).
    expect_equal(
      readLines(fs::path("tests", "cypress.bak", "e2e", "app.cy.js")),
      "old spec"
    )
    expect_equal(readLines(fs::path("tests", "cypress.config.js.bak")), "old config")

    # Fresh template written in place.
    expect_true(fs::file_exists(fs::path("tests", "cypress", "e2e", "app.cy.js")))
    expect_false(
      identical(readLines(fs::path("tests", "cypress", "e2e", "app.cy.js")), "old spec")
    )
  })
})
