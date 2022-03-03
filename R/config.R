# Given a path without extension, read either `{path}.yml` or `{path}.yaml`.
read_yaml <- function(path) {
  yml <- paste0(path, ".yml")
  yaml <- paste0(path, ".yaml")
  if (fs::file_exists(yml)) {
    if (fs::file_exists(yaml)) {
      cli::cli_alert_warning("Both '{yml}' and '{yaml}' found; reading '{yml}'.")
    }
    yaml::read_yaml(yml)
  } else if (fs::file_exists(yaml)) {
    yaml::read_yaml(yaml)
  } else {
    cli::cli_abort("Neither '{yml}' nor '{yaml}' found.")
  }
}

rhino_config_definition <- list(
  list(
    name = "sass",
    options = c("node", "r"),
    required = TRUE
  ),
  list(
    name = "legacy_entrypoint",
    options = c("app_dir", "source", "box_top_level"),
    required = FALSE
  )
)

validate_config <- function(definition, config) {
  stopifnot(is.list(config))

  allowed_fields <- purrr::map_chr(definition, `[[`, "name")
  for (field in names(config)) {
    if (!(field %in% allowed_fields)) {
      stop() # Unknown field.
    }
  }

  for (field in definition) {
    if (field$name %in% names(config)) {
      value <- config[[field$name]]
      if (!(value %in% field$options)) {
        stop() # Invalid value.
      }
    } else if (field$required) {
      stop() # Missing required field.
    }
  }
}

read_config <- function() {
  config <- read_yaml("rhino")
  validate_config(rhino_config_definition, config)
  config
}
