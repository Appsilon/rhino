test_that("use_agents_md() copies AGENTS.md to the working directory", {
  withr::with_tempdir({
    use_agents_md()

    expect_true(fs::file_exists("AGENTS.md"))
    contents <- readLines("AGENTS.md")
    expect_true(any(grepl("## Importing and exporting", contents, fixed = TRUE)))
  })
})

test_that("use_agents_md() errors when AGENTS.md already exists", {
  withr::with_tempdir({
    fs::file_create("AGENTS.md")
    expect_error(use_agents_md())
  })
})
