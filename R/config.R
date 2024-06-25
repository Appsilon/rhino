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

option_validator <- function(...) {
  list(
    check = function(value) value %in% c(...),
    help = cli::format_inline("Allowed values: {c(...)}.")
  )
}

positive_integer_validator <- list(
  check = function(value) is.integer(value) && value > 0,
  help = "Expected positive integer."
)

rhino_config_definition <- list(
  list(
    name = "sass",
    validator = option_validator("node", "r", "custom"),
    required = TRUE
  ),
  list(
    name = "legacy_entrypoint",
    validator = option_validator("app_dir", "source", "box_top_level"),
    required = FALSE
  ),
  list(
    name = "legacy_max_lint_r_errors",
    validator = positive_integer_validator,
    required = FALSE
  )
)

validate_config <- function(definition, config) {
  if (is.null(config)) config <- list()
  if (!is.list(config)) {
    cli::cli_abort(c(
      "Config should be a named list (a YAML object).",
      i = "The received config has class {.cls {class(config)}}."
    ))
  }

  known_fields <- purrr::map_chr(definition, `[[`, "name")
  for (field in names(config)) {
    if (!(field %in% known_fields)) {
      cli::cli_abort("Unknown config field '{field}'.")
    }
  }

  for (field in definition) {
    if (field$name %in% names(config)) {
      value <- config[[field$name]]
      if (!field$validator$check(value)) {
        cli::cli_abort(c(
          "Invalid value '{value}' for field '{field$name}'.",
          i = field$validator$help
        ))
      }
    } else if (field$required) {
      cli::cli_abort("Missing required field '{field$name}'.")
    }
  }
}

read_config <- function() {
  config <- read_yaml("rhino")
  validate_config(rhino_config_definition, config)
  config
}
