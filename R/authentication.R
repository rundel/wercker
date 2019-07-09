#' Get wercker token
#'
#' \code{wercker_get_token} obtains the user's wercker authentication token.
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
#' wercker_get_token()
#' }
#'
#' @family authentication functions
#'
#' @export
#'
wercker_get_token = function() {

  token = Sys.getenv("WERCKER_PAT", "")
  if (token != "")
    return(token)

  token = Sys.getenv("WERCKER_TOKEN", "")
  if (token != "")
    return(token)

  if (file.exists("~/.wercker/token")) {
    wercker_set_token("~/.wercker/token")
    return(wercker_get_token())
  }

  usethis::ui_stop(paste(
    "Unable to locate wercker token, please use {usethis::ui_code(\"wercker_set_token()\")}",
    "or define the {usethis::ui_value(\"WERCKER_TOKEN\")} environmental variable."
  ))
}


#' Set wercker token
#'
#' \code{wercker_set_token} defines the user's wercker authentication token,
#' this value is then accessed usin \code{wercker_get_token}
#'
#' @param token character, either the path of a file contained the token or the actual token.
#'
#' @examples
#' \dontrun{
#' wercker_set_token("~/.wercker/token")
#' wercker_set_token("0123456789ABCDEF0123456789ABCDEF01234567")
#' }
#'
#' @family authentication functions
#'
#' @export
#'
wercker_set_token = function(token) {
  token = as.character(token)

  if (file.exists(token))
    token = readLines(token, warn=FALSE)

  Sys.setenv("WERCKER_PAT" = token)
}


#' Test wercker token
#'
#' \code{wercker_test_token} checks if a token is valid by attempting to authenticate with the Wercker's api.
#'
#' @param token character or missing, if missing the token is obtained using \code{wercker_get_token}.
#'
#' @examples
#' \dontrun{
#' wercker_test_token()
#' wercker_test_token("bad_token")
#' }
#'
#' @family authentication functions
#'
#' @export
#'
wercker_test_token = function(token = wercker_get_token()) {
  res = purrr::safely(wercker_api_get_my_profile)()

  status_msg(
    res,
    "Your wercker token is functioning correctly.",
    "Your wercker token failed to authenticate."
  )
}
