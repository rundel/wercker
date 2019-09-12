wercker_api_checkout_key = function() {
  req = httr::POST(
    "https://app.wercker.com/api/v2/checkoutKeys",
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json"
  )

  httr::stop_for_status(req)
  httr::content(req)
}

wercker_api_link_key = function(repo, provider = "github", key) {
  repo_owner = get_repo_owner(repo)
  repo_name  = get_repo_name(repo)

  req = httr::POST(
    paste0("https://app.wercker.com/api/v2/checkoutKeys/",key[["id"]],"/link"),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json",
    body = list(
      scmName     = repo_name,
      scmOwner    = repo_owner,
      scmProvider = provider
    )
  )
  httr::stop_for_status(req)
  res = httr::content(req)
  if (is.null(res[["success"]]))
    usethis::ui_stop("Linking ssh keys failed.")

  res
}

wercker_api_add_app = function(repo, provider, privacy, wercker_org_id, key) {
  repo_owner = get_repo_owner(repo)
  repo_name  = get_repo_name(repo)

  req = purrr::safely(httr::POST)(
    paste0("https://app.wercker.com/api/v2/applications"),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token()),
      origin = "https://app.wercker.com",
      referer = "https://app.wercker.com/applications/create"
    ),
    encode = "json",
    body = list(
      checkoutKeyId = key[["id"]],
      owner         = wercker_org_id,
      privacy       = privacy,
      pushKey       = "",
      scmName       = repo_name,
      scmOwner      = repo_owner,
      scmProvider   = provider,
      sshUrl        = "",
      stack         = "6"
    ),
    httr::timeout(120)
  )

  if (failed(req)) {
    msg = req[["error"]][["message"]]

    if (msg != "Unexpected EOF")
      usethis::ui_warn(msg)

    NULL
  } else {
    httr::content(req[["result"]])
  }
}

wercker_api_add_build_pipeline = function(id, privacy) {

  req = httr::POST(
    paste0("https://app.wercker.com/api/v3/pipelines"),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json",
    body = list(
      pipelineName = "build",
      ymlPipeline = "build",
      type = "git",
      application = id,
      permissions = privacy,
      name = "build",
      setScmProviderStatus = TRUE
    )
  )

  httr::stop_for_status(req)
  httr::content(req)
}

wercker_api_delete_app = function(repo) {

  id = get_wercker_app_id(repo)

  req = httr::POST(
    paste0("https://app.wercker.com/deleteproject"),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json",
    body = list(
      id = id
    )
  )

  httr::stop_for_status(req)
  httr::content(req)
}


wercker_api_get_pipelines = function(repo) {
  stopifnot(length(repo) == 1)
  require_valid_repo(repo)

  req = httr::GET(
    paste0("https://app.wercker.com/api/v3/applications/", repo, "/pipelines?limit=60"),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json"
  )

  httr::stop_for_status(req)
  httr::content(req)
}

wercker_api_get_app = function(repo, strict = FALSE) {
  stopifnot(length(repo) == 1)
  require_valid_repo(repo)

  req = httr::GET(
    paste0("https://app.wercker.com/api/v3/applications/", repo),
    httr::add_headers(
      Authorization = paste("Bearer", wercker_get_token())
    ),
    encode = "json"
  )

  if (strict)
    httr::stop_for_status(req)

  if (httr::status_code(req) < 300) {
    httr::content(req)
  } else {
    NULL
  }
}



get_wercker_app_id = function(repo) {
  apps = purrr::map(repo, wercker_api_get_app)
  purrr::map_chr(apps, "id", .default=NA)
}

wercker_pipelines_exist = function(repo) {
  p = purrr::map(repo, wercker_api_get_pipelines)
  p = purrr::map_int(p, length)
  p != 0
}

wercker_app_exists = function(repo) {
  p = purrr::map(repo, wercker_api_get_app)
  purrr::map_lgl(p, ~!is.null(.x))
}



wercker_add_app = function(repo, wercker_org = get_repo_owner(repo),
                           privacy = c("public", "private"),
                           provider = "github") {
  privacy = match.arg(privacy)
  org_id = get_wercker_org_id(wercker_org)[["id"]]

  key = wercker_api_checkout_key()
  wercker_api_link_key(repo, provider, key)

  wercker_api_add_app(repo, provider, privacy, org_id, key)

  Sys.sleep(10)
  id = wercker_api_get_app(repo, strict = TRUE)[["id"]]
  stopifnot(!is.null(id))

  wercker_api_add_build_pipeline(id, privacy)

  invisible(NULL)
}


#' Check for the existance of wercker apps and pipelines
#'
#' Returns a data frame with details on each of the provided repos
#'
#' @param repo one or more repo names in `owner/repo` format
#'
#' @family app functions
#'
#' @export
#'
wercker_check = function(repo) {
  apps = wercker_app_exists(repo)
  pipes = rep(FALSE, length(repo))
  pipes[apps] = wercker_pipelines_exist(repo[apps])

  tibble::data_frame(
    repo = repo,
    app_exists = apps,
    pipelines_exists = pipes
  )
}

#' Create a wercker app for an existing github repo
#'
#' @param repo one or more repo names in `owner/repo` format.
#' @param wercker_org name of the owning organization on wercker, only needs to be provided if this differs from github.
#' @param add_badge should a wercker badge be added to the github repo's README.md
#'
#' @family app functions
#'
#' @export
wercker_add = function(repo, wercker_org = get_repo_owner(repo), add_badge=TRUE) {
  require_valid_repo(repo)

  purrr::map2(
    repo, wercker_org,
    function(repo, wercker_org) {

      existing_apps = wercker_apps(wercker_org, simplify = FALSE)[["name"]]

      if (get_repo_name(repo) %in% existing_apps) {
        usethis::ui_info(
          "Skipping {usethis::ui_value(repo)}, wercker app already exists ..."
        )
      } else {
        res = purrr::safely(wercker_add_app)(repo, wercker_org)

        status_msg(
          res,
          glue::glue("Creating wercker app for {usethis::ui_value(repo)}."),
          glue::glue("Creating wercker app for {usethis::ui_value(repo)} failed.")
        )

        if (failed(res) & wercker_app_exists(repo))
          wercker_api_delete_app(repo)

        if (succeeded(res) & add_badge)
          wercker_add_badge(repo)
      }

      res
    }
  )
}



