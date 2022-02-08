if (file.exists("renv")) {
  source("renv/activate.R")
  capture.output(renv::restore(packages = "rhino", prompt = FALSE), file = nullfile())
} else {
  # The `renv` directory is automatically skipped when deploying with rsconnect.
  message("No 'renv' directory found; renv won't be activated.")
}

rhino:::rprofile_init()
