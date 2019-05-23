#' wercker: A package for github based classroom and assignment management
#'
#'
#'
#' @section authentication functions:
#'
#' * [`get_wercker_token`] - get wercker token
#' * [`set_wercker_token`] - set wercker token
#' * [`test_wercker_token`] - test wercker token
#'
#' @section wercker applications:
#'
#' * [`add_wercker`] - add wercker to github repo
#' * [`check_wercker`] - check that= wercker app(s) have been created
#'
#' @section wercker user:
#'
#' * [`get_wercker_orgs`] - returns details on user's organizations
#' * [`get_wercker_apps`] - returns details on user's / organization's applications
#' * [`create_wercker_org`] - creates wercker organization(s)
#'
#' @section badges:
#'
#' * [`get_wercker_badge`] - get link to a wercker app's badge
#' * [`add_wercker_badge`] - add wercker badge to github repo
#'
#' @section environmental variables:
#'
#' * [`add_wercker_env_var`] - add a wercker environmental variable
#' * [`get_wercker_env_vars`] - get a wercker environmental variable
#'
#' @section local wercker builds:
#'
#' * [`wercker_local_build`] - build a local repo using wercker cli
#'
#' @docType package
#' @name wercker
NULL
