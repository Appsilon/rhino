test_that("rename_template_path() works", {
  path <- fs::path("dot.hidden", "app.Rproj.template")
  expected <- fs::path(".hidden", "app.Rproj")
  expect_identical(rename_template_path(path), expected)
})

test_that("rename_template_path() is not too eager", {
  path1 <- fs::path("dots")
  path2 <- fs::path("atemplate")
  expect_identical(rename_template_path(path1), path1)
  expect_identical(rename_template_path(path2), path2)
})

test_that("next_backup_path() picks a fresh suffix when previous backups are taken", {
  withr::with_tempdir({
    expect_equal(next_backup_path("foo.txt"), "foo.txt.bak")

    fs::file_create("foo.txt.bak")
    expect_equal(next_backup_path("foo.txt"), "foo.txt.bak.1")

    fs::file_create("foo.txt.bak.1")
    expect_equal(next_backup_path("foo.txt"), "foo.txt.bak.2")
  })
})

test_that("handle_existing_paths() backs up an existing file when the user picks option 2", {
  withr::with_tempdir({
    writeLines("original", "foo.txt")

    result <- testthat::with_mocked_bindings(
      prompt_conflict = function(paths) 2L,
      handle_existing_paths("foo.txt")
    )

    expect_true(result)
    expect_false(fs::file_exists("foo.txt"))
    expect_true(fs::file_exists("foo.txt.bak"))
    expect_equal(readLines("foo.txt.bak"), "original")
  })
})

test_that("handle_existing_paths() backs up an existing directory tree", {
  withr::with_tempdir({
    fs::dir_create(fs::path("cypress", "e2e"))
    writeLines("spec", fs::path("cypress", "e2e", "app.cy.js"))

    result <- testthat::with_mocked_bindings(
      prompt_conflict = function(paths) 2L,
      handle_existing_paths("cypress")
    )

    expect_true(result)
    expect_false(fs::dir_exists("cypress"))
    expect_true(fs::file_exists(fs::path("cypress.bak", "e2e", "app.cy.js")))
    expect_equal(readLines(fs::path("cypress.bak", "e2e", "app.cy.js")), "spec")
  })
})

test_that("handle_existing_paths() backs up only the paths that exist", {
  withr::with_tempdir({
    fs::dir_create("cypress")
    # `cypress.config.js` intentionally absent.

    result <- testthat::with_mocked_bindings(
      prompt_conflict = function(paths) 2L,
      handle_existing_paths(c("cypress", "cypress.config.js"))
    )

    expect_true(result)
    expect_true(fs::dir_exists("cypress.bak"))
    expect_false(fs::file_exists("cypress.config.js.bak"))
  })
})

test_that("handle_existing_paths() proceeds without prompting when nothing exists", {
  withr::with_tempdir({
    prompted <- FALSE
    result <- testthat::with_mocked_bindings(
      prompt_conflict = function(paths) {
        prompted <<- TRUE
        1L
      },
      handle_existing_paths(c("nope", "also-nope"))
    )

    expect_true(result)
    expect_false(prompted)
  })
})

test_that("handle_existing_paths() leaves files alone when the user picks Abort", {
  withr::with_tempdir({
    writeLines("original", "foo.txt")

    result <- testthat::with_mocked_bindings(
      prompt_conflict = function(paths) 1L,
      handle_existing_paths("foo.txt")
    )

    expect_false(result)
    expect_true(fs::file_exists("foo.txt"))
    expect_false(fs::file_exists("foo.txt.bak"))
    expect_equal(readLines("foo.txt"), "original")
  })
})

test_that("prompt_conflict() errors in a non-interactive session", {
  expect_error(prompt_conflict("foo.txt"), regexp = "already exist")
})
