#' Get Users by Product ID, Type, and Various Date Spans
#'
#' For a given period of time (a day, week, or month) Revenera's API
#' summarizes and returns the number of active users. With this function
#' you can return daily, weekly, or monthly active users for multiple
#' product ids.
#'
#' You can specify a start and end date but Revenera does not store
#' an indefinite period of historical data.
#'
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more
#' secure; this package does not require you to use any one in particular.
#'
#' The optional_json parameter is available so that other optional arguments
#' can be added to the api request. This will require the user to consult
#' the API documentation. See README for an example.
#'
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#' @param user_type One of "active," "new", or "lost."
#' @param rev_date_type Level of aggregation, Revenera will accept
#' "day", "week", or "month".
#' @param rev_start_date Date formatted YYYY-MM-DD. Revenera may give
#' an error if you try to go back too far.
#' @param rev_end_date Date formatted YYYY-MM-DD.
#' @param rev_session_id Session ID established by the connection to
#' Revenera API. This can be obtained with revenera_auth().
#' @param rev_username Revenera username.
#' @param lost_days Required for lost users, the number of consecutive
#' days of inactivity before a client is considered lost.
#' @param lost_reported Required for lost users, should the lost date
#' be the first day of inactivity ("dateLastSeen") or date
#' client is considered lost ("dateDeclaredLost").
#' @param optional_json Optional JSON text to add to the request body
#' for things like global filters.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr "map_dfr"
#' @import httr
#' @import jsonlite
#'
#' @return Data frame with active users for each product id and
#' unique date within the range
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' product_ids_list <- c("123", "456", "789")
#' start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
#' end_date <- Sys.Date() - 1
#' session_id <- revenera_auth(rev_user, rev_pwd)
#' global_filter <- paste0(
#'   ",\"globalFilters\":{\"licenseType\":",
#'   "{\"type\":\"string\",\"value\":\"purchased\"}}"
#' )
#' monthly_active_users <- get_users(product_ids_list,
#'   "active",
#'   "month",
#'   start_date,
#'   end_date,
#'   session_id,
#'   rev_user,
#'   optional_json = global_filter
#' )
#' }
get_users <- function(rev_product_ids, user_type, rev_date_type, rev_start_date,
                      rev_end_date, rev_session_id, rev_username,
                      lost_days = 30, lost_reported = "dateLastSeen",
                      optional_json = "") {
  . <- NA # prevent variable binding note for the dot

  get_by_product <- function(x, rev_date_type) {
    request_body <- paste0("{\"user\":\"", rev_username,
      "\",\"sessionId\":\"",
      rev_session_id,
      "\",\"productId\":",
      x,
      ",\"startDate\":\"",
      rev_start_date,
      "\",\"stopDate\":\"",
      rev_end_date,
      "\",\"daysUntilDeclaredLost\":",
      lost_days,
      ",\"dateReportedLost\":\"",
      lost_reported,
      "\",\"dateSplit\":\"",
      rev_date_type,
      "\",\"startAtClientId\":",
      jsonlite::toJSON(ifelse(
        exists("content_json"), content_json$nextClientId,
        NA_character_
      ),
      auto_unbox = TRUE
      ),
      paste0(
        ",\"clientStatus\":",
        jsonlite::toJSON(array(c(user_type)),
          auto_unbox = TRUE
        )
      ),
      optional_json,
      "}",
      sep = ""
    )

    request <- httr::RETRY("POST",
      url = paste0(
        "https://api.revulytics.com/",
        "reporting/generic/dateRange?",
        "responseFormat=raw"
      ),
      body = request_body,
      encode = "json",
      times = 4,
      pause_min = 10,
      terminate_on = NULL,
      terminate_on_success = TRUE,
      pause_cap = 5
    )

    check_status(request)

    request_content <- httr::content(request, "text", encoding = "ISO-8859-1")

    content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)

    iteration_df <- as.data.frame(unlist(content_json$results)) %>%
      cbind(rownames(.)) %>%
      dplyr::rename(user_date = 2, users = 1) %>%
      dplyr::mutate(
        user_date = as.Date(substr(.data$user_date, 1, 10)),
        revenera_product_id = x
      )
    rownames(iteration_df) <- NULL
    return(iteration_df)
  }

  df <- purrr::map_dfr(rev_product_ids, get_by_product, rev_date_type)

  return(df)
}
