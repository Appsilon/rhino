# Create Rhino application

Generates the file structure of a Rhino application. Can be used to
start a fresh project or to migrate an existing Shiny application
created without Rhino.

## Usage

``` r
init(
  dir = ".",
  github_actions_ci = TRUE,
  agents_instructions = TRUE,
  e2e_tests = TRUE,
  rhino_version = "rhino",
  force = FALSE
)
```

## Arguments

- dir:

  Name of the directory to create application in.

- github_actions_ci:

  Should the GitHub Actions CI be added?

- agents_instructions:

  Should an `AGENTS.md` file with guidance for AI coding agents be
  added?

- e2e_tests:

  Should the Cypress end-to-end test structure be added?

- rhino_version:

  When using an existing `renv.lock` file, Rhino will install itself
  using `renv::install(rhino_version)`. You can provide this argument to
  use a specific version / source, e.g.`"Appsilon/rhino@v0.4.0"`.

- force:

  Boolean; force initialization? By default, Rhino will refuse to
  initialize a project in the home directory.

## Value

None. This function is called for side effects.

## Details

The recommended steps for migrating an existing Shiny application to
Rhino:

1.  Put all app files in the `app` directory, so that it can be run with
    `shiny::shinyAppDir("app")` (assuming all dependencies are
    installed).

2.  If you have a list of dependencies in form of
    [`library()`](https://rdrr.io/r/base/library.html) calls, put them
    in the `dependencies.R` file. If this file does not exist, Rhino
    will generate it based on `renv::dependencies("app")`.

3.  If your project uses `{renv}`, put `renv.lock` and `renv` directory
    in the project root. Rhino will try to only add the necessary
    dependencies to your lockfile.

4.  Run `rhino::init()` in the project root.
