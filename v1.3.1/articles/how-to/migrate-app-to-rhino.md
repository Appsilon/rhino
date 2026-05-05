# How-to: Migrate app to Rhino

This guide aims to make your application up and running using Rhino as
quickly as possible. Lets assume an application has a following
structure:

    .
    ├── utils
    │   ├── foo.R
    │   └── bar.R
    ├── www
    │   ├── main.css
    │   └── main.js
    ├── server.R
    └── ui.R

The migration process should not be affected by the combination of
server.R, ui.R, global.R, and app.R files in your application, or lack
of thereof.

## Prepare Your Application for `rhino::init()`

The first step is moving all application source files to a new `app`
directory:

    .
    └── app
        ├── utils
        │   ├── bar.R
        │   └── foo.R
        ├── www
        │   ├── main.css
        │   └── main.js
        ├── server.R
        └── ui.R

Once source files are moved, if you have a list of
[`library()`](https://rdrr.io/r/base/library.html) calls put it in
`dependencies.R` in the root directory. If you do not have such list,
then Rhino will try to create one for you in [initialization
step](#initialize-your-rhino-application).

    .
    ├── app
    │   ├── utils
    │   │   ├── bar.R
    │   │   └── foo.R
    │   ├── www
    │   │   ├── main.css
    │   │   └── main.js
    │   ├── server.R
    │   └── ui.R
    └── dependencies.R

After doing so, you should be able to run your application using
`shiny::shinyAppDir("app")`.

### *What if:* My App Uses renv

If you have used renv in your application, then chances are your active
renv session does not have Rhino installed. To address this either
deactivate renv or run `renv::install("rhino")`.

Apart from additional files related to renv, the target file structure
is no different than the one presented above.

## Initialize Your Rhino Application

Having your application prepared, you can now run
[`rhino::init()`](https://appsilon.github.io/rhino/v1.3.1/reference/init.md).

    .
    ├── .github
    │   └── workflows
    │       └── rhino-test.yml
    ├── app
    │   ├── js
    │   │   └── index.js
    │   ├── logic
    │   │   └── __init__.R
    │   ├── static
    │   │   └── favicon.ico
    │   ├── styles
    │   │   └── main.scss
    │   ├── utils
    │   │   ├── bar.R
    │   │   └── foo.R
    │   ├── view
    │   │   └── __init__.R
    │   ├── www
    │   │   ├── main.css
    │   │   └── main.js
    │   ├── main.R
    │   ├── server.R
    │   └── ui.R
    ├── renv
    │   └── ...
    ├── tests
    │   ├── cypress
    │   │   ├── integration
    │   │   └── .gitignore
    │   ├── testthat
    │   │   └── test-main.R
    │   └── cypress.json
    ├── .Rprofile
    ├── .lintr
    ├── .renvignore
    ├── app.R
    ├── dependencies.R
    ├── old.Rprofile
    ├── renv.lock
    ├── rhino.yml
    └── app.Rproj

If you did not use renv before, then Rhino initialized it for you.
However, if you did use renv, then Rhino added necessary dependencies to
`renv.lock` file.

### *What if:* My App Had .Rprofile

Your `.Rprofile` has been moved to `old.Rprofile`. If it contained any
relevant bits (e.g. setting options), then carry it over to `.Rprofile`
created by Rhino.

## Configure Your Rhino Application

The last step to get started with Rhino is configuring it. A minimal
setup that allows running the application is setting `legacy_entrypoint`
in `rhino.yml`. To be able to run application immediately set
`legacy_entrypoint: app_dir`, as this approach requires no further
adjustments to application’s structure.

As you adjust adjust your application to fit best practices suggested by
Rhino, you can modify `legacy_entrypoint`. Ultimately, when application
is fully migrated to Rhino, `legacy_entrypoint` setting can be removed
from `rhino.yml`. Refer to [Next Steps](#next-steps) section to see how
to continue improving your application!

## Next Steps

### Migrating JavaScript Code

TODO: something along the lines of
[`build_js()`](https://appsilon.github.io/rhino/v1.3.1/reference/build_js.md)
details

### Migrating CSS styles to SASS

TODO

### Boxifying Application

TODO: adjusting application to fit structure proposed by Rhino

## Additional notes

The process described in
[`rhino::init()`](https://appsilon.github.io/rhino/v1.3.1/reference/init.md)
documentation, albeit not in great detail. The first step is to put all
app files in the `app` directory, so it can be run with
`shinyAppDir("app")`. Practical experience of migrating apps shows that
it’s a useful step which quickly lets you verify whether the app still
works.

The process can be a bit unintuitive however. For example, if you
already have an `app.R` file and ui/server/global in `R` subdirectory,
you should still move the whole structure under `app`. In this case
you’ll end up with `app.R`, `app/app.R` and ui/server/global in
`app/R/`. Having two `app.R` files might feel awkward.

In general you use
[`rhino::init()`](https://appsilon.github.io/rhino/v1.3.1/reference/init.md)
for migration. This cannot be done via RStudio GUI.

If you already have `.Rprofile` with renv when migrating, you’ll load it
and won’t have Rhino inside. You need to run
[`rhino::init()`](https://appsilon.github.io/rhino/v1.3.1/reference/init.md)
from a different directory (or perhaps run renv::deactivate()).

Rhino will renv::load() your renv.lock. In particular it will set your
`options("repos"`) based on `renv.lock`.

What to do when I get “unsatisfied dependencies” during migration?
