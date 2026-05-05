# Watch and automatically run R tests

Watches R files in the `app` directory and `tests/testthat` directory
for changes. When code files in `app` change, all tests are rerun. When
test files change, only the changed test file is rerun.

## Usage

``` r
auto_test_r(reporter = NULL, filter = NULL, hash = TRUE)
```

## Arguments

- reporter:

  `{testthat}` reporter to use. If NULL, will use
  [`testthat::default_reporter()`](https://testthat.r-lib.org/reference/default_reporter.html)
  for tests when running all tests and
  [`testthat::default_compact_reporter()`](https://testthat.r-lib.org/reference/default_reporter.html)
  for single file tests. See [`{testthat}`
  reporters](https://testthat.r-lib.org/reference/Reporter.html) for
  more details.

- filter:

  filter passed to
  [`testthat::test_dir()`](https://testthat.r-lib.org/reference/test_dir.html).
  If not NULL, only tests with file names matching this regular
  expression will be executed. Matching is performed on the file name
  after it's stripped of "test-" and ".R". Does not affect the case when
  a test file is changed. In this case, this test file is rerun.

- hash:

  Logical. Whether to use file hashing to detect changes. Default is
  TRUE. If FALSE, file modification times are used instead.

## Value

None. This function is called for side effects.

## Examples

``` r
if (interactive()) {
  # Watch files and automatically run tests when changes are detected
  auto_test_r()
}
```
