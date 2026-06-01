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

test_that("handle_existing_file() backs up the existing file when the user picks option 2", {
  withr::with_tempdir({
    writeLines("original", "foo.txt")

    result <- testthat::with_mocked_bindings(
      prompt_file_conflict = function(path) 2L,
      handle_existing_file("foo.txt")
    )

    expect_true(result)
    expect_false(fs::file_exists("foo.txt"))
    expect_true(fs::file_exists("foo.txt.bak"))
    expect_equal(readLines("foo.txt.bak"), "original")
  })
})

test_that("handle_existing_file() leaves the file alone when the user picks Abort", {
  withr::with_tempdir({
    writeLines("original", "foo.txt")

    result <- testthat::with_mocked_bindings(
      prompt_file_conflict = function(path) 1L,
      handle_existing_file("foo.txt")
    )

    expect_false(result)
    expect_true(fs::file_exists("foo.txt"))
    expect_false(fs::file_exists("foo.txt.bak"))
    expect_equal(readLines("foo.txt"), "original")
  })
})

test_that("prompt_file_conflict() errors in a non-interactive session", {
  expect_error(prompt_file_conflict("foo.txt"), regexp = "already exists")
})
