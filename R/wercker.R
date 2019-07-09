#' wercker: A package for github based classroom and assignment management
#'
#'
#'
#' @section authentication functions:
#'
#' * [`wercker_get_token`] - get wercker token
#' * [`wercker_set_token`] - set wercker token
#' * [`wercker_test_token`] - test wercker token
#'
#' @section wercker applications:
#'
#' * [`wercker_add`] - add wercker to github repo
#' * [`wercker_check`] - check that= wercker app(s) have been created
#'
#' @section wercker user:
#'
#' * [`wercker_orgs`] - returns details on user's organizations
#' * [`wercker_apps`] - returns details on user's / organization's applications
#' * [`wercker_create_org`] - creates wercker organization(s)
#'
#' @section badges:
#'
#' * [`wercker_get_badge`] - get link to a wercker app's badge
#' * [`wercker_add_badge`] - add wercker badge to github repo
#'
#' @section environmental variables:
#'
#' * [`wercker_add_env_var`] - add a wercker environmental variable
#' * [`wercker_env_vars`] - get a wercker environmental variable
#'
#' @section local wercker builds:
#'
#' * [`wercker_local_build`] - build a local repo using wercker cli
#'
#' @docType package
#' @name wercker
NULL
