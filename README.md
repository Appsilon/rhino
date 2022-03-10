# Rhino <a href="https://appsilon.github.io/rhino/"><img src="man/figures/rhino.png" align="right" alt="Rhino logo" height="140"></a>
> _Strong bones for your [Shiny](https://shiny.rstudio.com/) apps_

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rhino)](https://cran.r-project.org/package=rhino)
[![R build status](https://github.com/Appsilon/rhino/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/rhino/actions)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: LGPL-3.0](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)][LGPL-3.0 license]
<!-- badges: end -->

## Installation
```r
install.packages("rhino")
```

### Installing from GitHub
To install latest development version or a specific one, run one of the following commands.
```r
# install.packages("remotes")
remotes::install_github("Appsilon/rhino")

# Installing rhino either from a specific release or a branch requires providing `ref` argument:
remotes::install_github("Appsilon/rhino", ref = "v0.5.0")
```


## Usage
### :building_construction: Create a Shiny Application from Scratch
Running `rhino::init()` will create a following application structure for you. Once that is done
simply run `shiny::runApp()` to start a minimal Rhino application! :rocket:

<details>
  <summary><strong>Rhino Application Structure</strong> <em>(click to unfold)</em></summary>
  <!-- The blank line below this comment keeps formatting intact -->

  ```
  .
  ├── app
  │   ├── js
  │   │   └── index.js
  │   ├── logic
  │   │   └── __init__.R
  │   ├── static
  │   │   └── favicon.ico
  │   ├── styles
  │   │   └── main.scss
  │   ├── view
  │   │   └── __init__.R
  │   └── main.R
  ├── tests
  │   ├── cypress
  │   │   └── integration
  │   │       └── app.spec.js
  │   ├── testthat
  │   │   └── test-main.R
  │   └── cypress.json
  ├── app.R
  ├── app.Rproj
  ├── dependencies.R
  ├── renv.lock
  └── rhino.yml
  ```
</details>

With the structure prepared you can [configure Rhino](#wrench-configure-rhino-with-rhinoyml) or jump
straight into [development using Rhino](#construction-develop-a-shiny-application-with-rhino)!

---

### :recycle: Migrate an Existing Shiny Application to Rhino
To migrate an application to Rhino create an application from scratch as described above. Then refer
to [`rhino::init()` details section](https://appsilon.github.io/rhino/reference/init.html#details-1)
for a recommended approach of proceeding with the migration.

---

### :wrench: Configure Rhino with `rhino.yml`
Rhino uses its own `rhino.yml` config file for preserving your preferences. Currently available
options are described in the taxonomy below.

<details>
  <summary><strong><code>rhino.yml</code> Taxonomy</strong> <em>(click to unfold)</em></summary>
  <!-- The blank line below this comment keeps formatting intact -->

  ```yaml
  sass: string               # required | one of: "node", "r"
  legacy_entrypoint: string  # optional | one of: "app_dir", "source", "box_top_level"
  ```
</details>

##### `sass`
Configures whether [SASS](https://sass-lang.com/) should be build using [R
package](https://cran.r-project.org/package=sass) or [Node
package](https://www.npmjs.com/package/sass). The latter provides newest implementation, at a cost
of additional system dependencies for development (`node` and `yarn`).

##### `legacy_entrypoint`
This setting is useful when migrating an existing Shiny application to Rhino. For more details see
[`rhino::app()` details section](https://appsilon.github.io/rhino/reference/app.html#details-1).

---

### :construction: Develop a Shiny Application with Rhino
_TODO_


## Contributing
Pull requests are welcome! Please see our [contributing guidelines](.github/CONTRIBUTING.md) for more details.

| Tool           | Command                  | `devtools` equivalent    | Comment
|----------------|--------------------------|--------------------------|-
| Unit tests     | `testthat::test_local()` | `devtools::test()`       |
| Linter         | `lintr::lint_package()`  | `devtools::lint()`       |
| `pkgdown` site | `pkgdown::build_site()`  | `devtools::build_site()` | If built successfully, the website will be in `docs` directory.


## About
Rhino is distributed under [LGPL-3.0 license]. See [`LICENSE`](LICENSE) for more information.

Developed with :heart: at [Appsilon].

---

Appsilon is the **Full Service Certified RStudio Partner**. Learn more at [appsilon.com][Appsilon].

Get in touch: support+opensource@appsilon.com.

<a href="https://appsilon.com/careers/"><img src="http://d2v95fjda94ghc.cloudfront.net/hiring.png" alt="We are hiring!"></a>


<!-- Links -->
[LGPL-3.0 license]: https://opensource.org/licenses/LGPL-3.0
[Appsilon]: https://appsilon.com
