# Quarto website development
1. [Install Quarto](https://quarto.org/docs/get-started/).
2. (Optional) Build the function reference:
    1. Change working directory to `quarto/tools`.
    2. Restore renv: `Rscript -e 'renv::restore(clean = TRUE)'`.
    3. Build: `Rscript build_reference.R`.
3. Run `quarto preview` in `quarto` directory.

The `.github/workflows/quarto.yml` workflow
will automatically build and deploy the website to `gh-pages` branch
whenever `main` is updated.
