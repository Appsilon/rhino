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
    expect_error(use_github_actions_ci(), regexp = "already exists")
  })
})
