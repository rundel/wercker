wercker_api_get_my_profile = function() {
  req = httr::GET(
    paste0("https://app.wercker.com/api/v2/profile"),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json"
  )
  httr::stop_for_status(req)
  httr::content(req)
}

wercker_api_get_my_orgs = function() {
  req = httr::GET(
    paste0("https://app.wercker.com/api/v2/users/me/organizations"),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json"
  )
  httr::stop_for_status(req)

  res = httr::content(req)
  purrr::map_dfr(res, wrap_list_elements)
}

#' Get my organization membership(s)
#'
#' Returns a data frame with details on a user's organizations
#'
#' @param simplify return a cleaned and simplified version of the organization data frame.
#'
#' @family user functions
#'
#' @export
#'
get_wercker_orgs = function(simplify = TRUE) {
  d = wercker_api_get_my_orgs()

  if (simplify)
    d = fix_df_names(d, c(name="username", id="id",url="url", created="creationDate"))

  d
}


wercker_api_get_apps = function(owner, limit = 100, skip = 0) {
  req = httr::GET(
    paste0("https://app.wercker.com/api/v3/applications/", owner,
           "?limit=",limit, "&skip=", skip),
    httr::add_headers(
      Authorization = paste("Bearer", get_wercker_token())
    ),
    encode = "json"
  )
  httr::stop_for_status(req)
  res = httr::content(req)

  purrr::map_dfr(res, wrap_list_elements)
}

#' Get user's apps
#'
#' Returns a data frame with details on a user's organizations
#'
#' @param owner one or more user or organization name(s).
#' @param simplify return a cleaned and simplified version of the organization data frame.
#'
#' @family user functions
#'
#' @export
#'
get_wercker_apps = function(owner, simplify = TRUE) {

  res = purrr::map_dfr(
    owner,
    function(owner) {
      limit = 100
      res = wercker_api_get_apps(owner, limit = limit, skip = 0)

      skip = limit
      while(nrow(res) %% limit == 0) {
        new_res = wercker_api_get_apps(owner, limit = limit, skip = skip)
        if (nrow(new_res) == 0)
          break

        res = rbind(res, new_res)
        skip = skip + limit
      }
    }
  )

  if (simplify) {
    owner_name = purrr::map_chr(res[["owner"]], "name")
    res[["repo"]] = paste(owner_name, res[["name"]], sep="/")

    res = fix_df_names(res, c(repo="repo", url="url", id="id",
                              created="createdAt", updated="updatedAt"))
  }

  res
}


get_wercker_org_id = function(org) {
  prof = wercker_api_get_my_profile()
  prof = wrap_list_elements(prof)
  prof = tibble::as_tibble(prof)
  prof = fix_df_names(prof, c(name="username", id="id"))
  prof[["id"]] = "me" # this is how they seem to code things currently <sigh>

  orgs = wercker_api_get_my_orgs()
  orgs = fix_df_names(orgs, c(name="username", id="id"))

  res = rbind(prof, orgs)
  res = res[res[["name"]] %in% org, ]

  missing = setdiff(org, res[["name"]])

  if (length(missing) > 0)
    usethis::ui_stop("Unable to located organization(s) {usethis::ui_value(missing)} on wercker.")

  res
}