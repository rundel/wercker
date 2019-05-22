get_env_var_id_helper = function(d) {
  repos = unique(d[["repo"]])

  cur_env = get_wercker_env_vars(unique(repo), warn = FALSE)
  cur_env = cur_env[,c("repo", "key","key_id")]

  merge(d, cur_env, by = c("repo", "key"), all.x = TRUE, all.y = FALSE)
}


wercker_api_add_env_var = function(repo, key, value, protected) {
  req = httr::POST(
    "https://app.wercker.com/api/v3/envvars",
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json",
    body = list(
      key       = as.character(key),
      protected = protected,
      scope     = "application",
      target    = get_wercker_app_id(repo),
      value     = as.character(value)
    )
  )

  httr::stop_for_status(req)
  httr::content(req)
}

wercker_api_change_env_var = function(repo, key, key_id, value, protected) {

  req = httr::PATCH(
    paste0("https://app.wercker.com/api/v3/envvars/", key_id),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json",
    body = list(
      key       = as.character(key),
      protected = protected,
      value     = as.character(value)
    )
  )

  httr::stop_for_status(req)
  httr::content(req)
}



wercker_api_set_env_var = function(repo, key, key_id, value, protected) {
 if (is.na(key_id)) {
   wercker_api_add_env_var(repo, key, value, protected)
 } else {
   wercker_api_change_env_var(repo, key, key_id, value, protected)
 }
}

#' Add environmental variable
#'
#' Adds an environmental variable to an exist wercker app.
#'
#' @param repo one or more repo names in `owner/repo` format
#' @param key name of the environmental variable
#' @param value value of the environmental variable
#' @param protected should the value be protected, proctected values cannot be retrieved.
#'
#' @family env var functions
#'
#' @export
#'
add_wercker_env_var = function(repo, key, value, protected=FALSE, overwrite = FALSE) {
  d = tibble::tibble(
    repo = repo,
    key = key,
    value = value,
    protected = protected,
    overwrite = overwrite
  )

  purrr::pwalk(
    get_env_var_id_helper(d),
    function(repo, key, value, protected, overwrite, key_id) {

      if (!overwrite & !is.na(key_id)) {
        usethis::ui_todo( paste(
          'Environment variable {usethis::ui_value(key)} already exists in {usethis::ui_value(repo)}.',
          'Use {usethis::ui_code("overwrite = TRUE")} to overwrite existing variables.'
        ))
      } else {
        res = purrr::safely(wercker_api_set_env_var)(repo, key, key_id, value, protected)

        status_msg(
          res,
          glue::glue("Adding env var {usethis::ui_value(key)} to {usethis::ui_value(repo)}."),
          glue::glue("Adding env var {usethis::ui_value(key)} to {usethis::ui_value(repo)} failed.")
        )
      }
    }
  )
}

wercker_api_get_env_var_id = function(repo, key) {
 env = wercker_api_get_env_var(repo)

 id = env[["key_id"]][env[["key"]] == key]
 stopifnot(length(id) == 1)

 id
}



wercker_api_get_env_var = function(repo) {
  id = get_wercker_app_id(repo)

  req = httr::GET(
    paste0("https://app.wercker.com/api/v3/envvars?scope=application&target=", id),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json"
  )
  httr::stop_for_status(req)

  res = httr::content(req)

  tibble::tibble(
    repo      = repo,
    repo_id   = id,
    key_id    = purrr::map_chr(res[["results"]], "id"),
    key       = purrr::map_chr(res[["results"]], "key"),
    value     = purrr::map_chr(res[["results"]], "value", .default = NA),
    protected = purrr::map_lgl(res[["results"]], "protected", .default = FALSE),
  )
}

#' Retrieve environmental variables
#'
#' Retrieves all environmental variables from a wercker app.
#'
#' @param repo one or more repo names in `owner/repo` format
#' @param warn enable messaging about failed retrievals (i.e. app does not exist)
#'
#' @family env var functions
#'
#' @export
get_wercker_env_vars = function(repo, warn = TRUE) {

  if (!warn)
    withr::local_options(list(usethis.quiet = TRUE))

  purrr::map_df(
    repo,
    function(repo) {
      res = purrr::safely(wercker_api_get_env_var)(repo)

      status_msg(
        res,
        fail = glue::glue("Failed to retrieve enivornmental variables for {usethis::ui_value(repo)}.")
      )

      res[["result"]]
    }
  )
}



wercker_api_delete_env_var = function(key_id) {
  if (is.na(key_id))
    stop("key does not exist")

  req = httr::DELETE(
    paste0("https://app.wercker.com/api/v3/envvars/", key_id),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json"
  )

  httr::stop_for_status(req)
}


#' Delete environmental variable(s)
#'
#' Delete environmental variable(s) from existing wercker app(s).
#'
#' @param repo one or more repo names in `owner/repo` format
#' @param key name of the environmental variable
#'
#' @family env var functions
#'
#' @export
#'
delete_wercker_env_var = function(repo, key) {
  d = tibble::tibble(
    repo = repo,
    key = key
  )

  d = get_env_var_id_helper(d)

  purrr::walk(
    d[["key_id"]],
    function(key_id) {
      res = purrr::safely(wercker_api_delete_env_var)(key_id)

      status_msg(
        res,
        glue::glue("Deleting env var {usethis::ui_value(key)} from {usethis::ui_value(repo)}."),
        glue::glue("Deleting env var {usethis::ui_value(key)} from {usethis::ui_value(repo)} failed.")
      )
    }
  )
}
