# How-to: Rhino 1.12 Migration Guide

Follow the steps outlined in this guide to migrate your project to Rhino
1.12. Before starting, ensure your Git working tree is clean, or back up
your project if not using Git.

Rhino 1.12 updates the bundled Node.js dependencies to address security
vulnerabilities. As a result, the **minimum supported Node.js version is
now 20**. There were no changes to the application structure.

This guide assumes you are migrating from Rhino 1.10 or 1.11. (Rhino
1.11 did not require a migration guide, as it introduced no changes
affecting project structure.) If you are currently using an older
version of Rhino, please review the older migration guides first:

- [Rhino 1.6 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-6.html).
- [Rhino 1.7 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-7.html).
- [Rhino 1.8 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-8.html).
- [Rhino 1.9 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-9.html).
- [Rhino 1.10 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-10.html).

## Step 1: Ensure Node.js 20 or later

Rhino’s JavaScript and Sass tools now require Node.js 20 or later. Check
your version with:

``` bash
node --version
```

If it is older than 20, install Node.js 20+ from
[nodejs.org](https://nodejs.org/en/download).

If you do not use Rhino’s Node.js-based tools
([`build_js()`](https://appsilon.github.io/rhino/dev/reference/build_js.md),
[`build_sass()`](https://appsilon.github.io/rhino/dev/reference/build_sass.md),
[`lint_js()`](https://appsilon.github.io/rhino/dev/reference/lint_js.md),
[`lint_sass()`](https://appsilon.github.io/rhino/dev/reference/lint_sass.md),
[`format_js()`](https://appsilon.github.io/rhino/dev/reference/format_js.md),
[`format_sass()`](https://appsilon.github.io/rhino/dev/reference/format_sass.md),
[`test_e2e()`](https://appsilon.github.io/rhino/dev/reference/test_e2e.md)),
this requirement does not apply and you can skip the `.rhino` steps
below.

## Step 2: Install Rhino 1.12

Use the following command to install Rhino 1.12 and update your
`renv.lock` file:

``` r
rhino::pkg_install("rhino@1.12.0")
```

After the installation, restart your R session to ensure all changes
take effect.

## Step 3: Remove the `.rhino` directory

The updated Node.js dependencies are picked up only when the `.rhino`
directory is regenerated. Remove it from the root of your project:

``` bash
rm -rf .rhino
```

This directory is recreated automatically and is safe to delete.

## Step 4: Regenerate the `.rhino` directory

Run any Node.js tool to recreate `.rhino` with the updated Node modules:

``` r
rhino::build_js()
```

## Step 5 (optional): Add an `AGENTS.md` file

Rhino now provides an `AGENTS.md` file with repository guidance for AI
coding agents. To add it to an existing project, run:

``` r
rhino::use_agents_md()
```

If your project does not already have a GitHub Actions CI workflow and
you would like one, you can now add it to an existing project with
[`rhino::use_github_actions_ci()`](https://appsilon.github.io/rhino/dev/reference/use_github_actions_ci.md).

## Step 6: Test your project

Test your project thoroughly to ensure everything works properly after
the migration. If you encounter any issues or have further questions,
don’t hesitate to reach out to us via [GitHub
Discussions](https://github.com/Appsilon/rhino/discussions).
