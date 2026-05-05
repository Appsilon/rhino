# How-to: Rhino 1.10 Migration Guide

Follow the steps outlined in this guide to migrate your project to Rhino
1.10. Before starting, ensure your Git working tree is clean, or back up
your project if not using Git.

This guide assumes you are migrating from Rhino 1.9. If you are
currently using an older version of Rhino, please review the older
migration guides first:

- [Rhino 1.6 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-6.html).
- [Rhino 1.7 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-7.html).
- [Rhino 1.8 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-8.html).
- [Rhino 1.9 Migration
  Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-9.html).

## Step 1: Install Rhino 1.10

Use the following command to install Rhino 1.10 and update your
`renv.lock` file:

``` r
rhino::pkg_install("rhino@1.10.0")
```

After the installation, restart your R session to ensure all changes
take effect.

## Step 2: Update your .Rprofile

Update your `.Rprofile` with `languageserver` parsers for
[`box::use`](https://klmr.me/box/reference/use.html), by running:

``` r
box.lsp::use_box_lsp()
```

Restart your R session so changes can take effect

Follow [“How-to: Auto-complete in VSCode”
guide](https://appsilon.github.io/rhino/v1.10.1/articles/how-to/) to
enable auto-complete in VSCode or Vim.

## Step 3 (optional, requires R \>= 4.3): Install `treesitter` and `treesitter.r`

To enable automated styling of
[`box::use`](https://klmr.me/box/reference/use.html) statements and
`box.linters::namespace_function_calls()` linter, install `treesitter`
and `treesitter.r`:

``` r
rhino::pkg_install(c("treesitter", "treesitter.r"))
```

## Step 4: Test your project

Test your project thoroughly to ensure everything works properly after
the migration. If you encounter any issues or have further questions,
don’t hesitate to reach out to us via [GitHub
Discussions](https://github.com/Appsilon/rhino/discussions).
