retry <- function(name, f, n = 5, delay = 3) {
  for (i in 1:n) {
    ok <- tryCatch(
      {
        f()
        TRUE
      },
      error = function(e) {
        message("error: ", conditionMessage(e))
        FALSE
      }
    )
    if (ok) break
    else Sys.sleep(delay)
  }
  paste(name, i, ifelse(ok, "OKAY", "FAIL"), sep = "-")
}

PKG <- "r-lib/rlang"
URL <- "https://api.github.com/repos/r-lib/rlang/contents/DESCRIPTION"

results <- character(0)

cat("::group::download\n")
withr::with_tempdir({
  results <- c(results, retry("download", function() download.file(URL, "DESCRIPTION")))
})
cat("::endgroup::\n")

cat("::group::curl\n")
withr::with_tempdir({
  results <- c(results, retry("curl", function() curl::curl_download(URL, "DESCRIPTION")))
})
cat("::endgroup::\n")

cat("::group::remotes\n")
results <- c(results, retry("remotes", function() remotes::install_github(PKG)))
cat("::endgroup::\n")

# Run renv in the end as it modifies the library paths.
cat("::group::renv\n")
withr::with_tempdir({
  renv::init()
  results <- c(results, retry("renv", function() renv::install(PKG)))
})
cat("::endgroup::\n")

cat("::notice::", results, "\n")
