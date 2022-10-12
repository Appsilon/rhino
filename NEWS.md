# rhino 1.1.1.9999

* Added a `NEWS.md` file to track changes to the package.
* Adds new supporting functions `is_dir_home()` and `check_dir_for_rhino()`. `is_dir_home()` should check if current working directory is the home directory. `check_dir_for_rhino()` should check for an existing `rhino` app structure in the current working directory. `init()` should prevent creating a `rhino` app when both of these checks return `TRUE`. `init()` gains a new argument `force`, default is `FALSE`, that should ignore these checks when `force = TRUE`.
