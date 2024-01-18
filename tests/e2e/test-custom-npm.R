local({
  tmp <- withr::local_tempdir()
  wrapper_path <- fs::path(tmp, "wrapper")
  touch_path <- fs::path(tmp, "it_works")

  # Prepare a wrapper script which creates an "it_works" file and runs npm.
  fs::file_create(wrapper_path, mode = "u=rwx")
  writeLines(
    c(
      "#!/bin/sh",
      paste("touch", touch_path),
      'exec npm "$@"'
    ),
    wrapper_path
  )

  # Use the wrapper script instead of npm.
  withr::local_envvar(RHINO_NPM = wrapper_path)
  rhino:::npm("--version")

  testthat::expect_true(fs::file_exists(touch_path))
})
