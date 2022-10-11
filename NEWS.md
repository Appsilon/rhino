# rhino 1.1.1.9999

* Added a `NEWS.md` file to track changes to the package.
* Adds `paths` argument to `lint_r()`. `paths` defaults to `NULL` and should lint `app` and `tests/testthat` as default. `paths` should take a vector of directory or file paths and return lint error or success messages whichever is appropriate. 
