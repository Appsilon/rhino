install.packages(c("treesitter", "treesitter.r"))

rhino::lint_r()
# Create bad scripts and test if formatting returns the expected result
test_file_path <- fs::path("app", "logic", "bad-style.R")
cat("bad_object_style=12", file = test_file_path)
testthat::expect_error(rhino::lint_r())
# Clean up
file.remove(test_file_path)
