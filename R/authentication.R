#' Get wercker token
#'
#' \code{get_wercker_token} obtains the user's wercker authentication token.
#'
#' This function looks for the token in the following places (in order):
#' \enumerate{
#'   \item Value of \code{wercker_token} variable in \code{.wercker} environment
#'   (this is where the package caches the token).
#'
#'   \item Value of \code{WERCKER_TOKEN} environmental variable.
#'
#'   \item Contents of \code{~/.wercker/token} file.
#' }
#'
#' @examples
#' \dontrun{
#' get_wercker_token()
#' }
#'
#' @family authentication functions
#'
#' @export
#'
get_wercker_token = function() {

  token = Sys.getenv("WERCKER_PAT", "")
  if (token != "")
    return(token)

  token = Sys.getenv("WERCKER_TOKEN", "")
  if (token != "")
    return(token)

  if (file.exists("~/.wercker/token")) {
    set_wercker_token("~/.wercker/token")
    return(get_wercker_token())
  }

  usethis::ui_stop(paste(
    "Unable to locate wercker token, please use {usethis::ui_code(\"set_wercker_token()\")}",
    "or define the {usethis::ui_value(\"WERCKER_TOKEN\")} environmental variable."
  ))
}


#' Set wercker token
#'
#' \code{set_wercker_token} defines the user's wercker authentication token,
#' this value is then accessed usin \code{get_wercker_token}
#'
#' @param token character, either the path of a file contained the token or the actual token.
#'
#' @examples
#' \dontrun{
#' set_wercker_token("~/.wercker/token")
#' set_wercker_token("0123456789ABCDEF0123456789ABCDEF01234567")
#' }
#'
#' @family authentication functions
#'
#' @export
#'
set_wercker_token = function(token) {
  stopifnot(!missing(token))
  stopifnot(is.character(token))

  if (file.exists(token))
    token = readLines(token, warn=FALSE)

  Sys.setenv("WERCKER_PAT" = token)
}


#' Test wercker token
#'
#' \code{test_wercker_token} checks if a token is valid by attempting to authenticate with the Wercker's api.
#'
#' @param token character or missing, if missing the token is obtained using \code{get_wercker_token}.
#'
#' @examples
#' \dontrun{
#' test_wercker_token()
#' test_wercker_token("bad_token")
#' }
#'
#' @family authentication functions
#'
#' @export
#'
test_wercker_token = function(token = get_wercker_token()) {
  res = purrr::safely(wercker_api_get_my_profile)()

  status_msg(
    res,
    "Your wercker token is functioning correctly.",
    c(
      "Your wercker token failed to authenticate.",
      "Error: {usethis::ui_value(res$error$message)}"
    )
  )
}
