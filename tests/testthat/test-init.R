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

test_that("use_agents_md() backs up an existing AGENTS.md when the user chooses to", {
  withr::with_tempdir({
    writeLines("original", "AGENTS.md")

    testthat::with_mocked_bindings(
      prompt_agents_md_conflict = function() 2L,
      use_agents_md()
    )

    expect_true(fs::file_exists("AGENTS.md.bak"))
    expect_equal(readLines("AGENTS.md.bak"), "original")
    expect_true(fs::file_exists("AGENTS.md"))
    expect_true(any(grepl("## Importing and exporting", readLines("AGENTS.md"), fixed = TRUE)))
  })
})

test_that("use_agents_md() aborts gracefully when the user chooses Abort from the prompt", {
  withr::with_tempdir({
    writeLines("original", "AGENTS.md")

    testthat::with_mocked_bindings(
      prompt_agents_md_conflict = function() 1L,
      expect_invisible(use_agents_md())
    )

    expect_false(fs::file_exists("AGENTS.md.bak"))
    expect_equal(readLines("AGENTS.md"), "original")
  })
})

test_that("next_backup_path() picks a fresh suffix when the default is taken", {
  withr::with_tempdir({
    expect_equal(next_backup_path("AGENTS.md"), "AGENTS.md.bak")

    fs::file_create("AGENTS.md.bak")
    expect_equal(next_backup_path("AGENTS.md"), "AGENTS.md.bak.1")

    fs::file_create("AGENTS.md.bak.1")
    expect_equal(next_backup_path("AGENTS.md"), "AGENTS.md.bak.2")
  })
})
