box::use(
  fs,
  pkgdown,
  rvest[html_elements, read_html],
  withr[with_dir],
)

html_to_qmd <- function(input_file, output_file) {
  contents <- read_html(input_file) |> html_elements(".contents") |> as.character()
  lines <- c("```{=html}", contents, "```")
  writeLines(lines, output_file)
}

main <- function() {
  pkgdown$build_reference(
    devel = FALSE,
    examples = FALSE,
    override = list(destination = "quarto")
  )
  with_dir(fs$path("quarto", "reference"), {
    for (file in fs$dir_ls(glob = "*.html")) {
      html_to_qmd(file, fs$path_ext_set(file, "qmd"))
    }
  })
}

with_dir(fs$path("..", ".."), main())
