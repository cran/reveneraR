% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_active_users.R
\name{get_active_users}
\alias{get_active_users}
\title{Get Active Users by Product ID and Various Date Spans}
\usage{
get_active_users(
  rev_product_ids,
  rev_date_type,
  rev_start_date,
  rev_end_date,
  rev_session_id,
  rev_username
)
}
\arguments{
\item{rev_product_ids}{A vector of Revenera product id's for which
you want active user data.}

\item{rev_date_type}{Level of aggregation, Revenera will accept
"day", "week", or "month".}

\item{rev_start_date}{Date formatted YYYY-MM-DD. Revenera may give
an error if you try to go back too far.}

\item{rev_end_date}{Date formatted YYYY-MM-DD.}

\item{rev_session_id}{Session ID established by the connection to
Revenera API. This can be obtained with revenera_auth().}

\item{rev_username}{Revenera username.}
}
\value{
Data frame with active users for each product id and
unique date within the range
}
\description{
For a given period of time (a day, week, or month) Revenera' API
summarizes and returns the number of active users. With this function
you can return daily, weekly, or monthly active users for multiple
product ids.
}
\details{
You can specify a start and end date but Revenera does not store
an indefinite period of historical data. In my experience this is
three years but I do not know if this varies on a product or client
level.

It is not recommended that your username be stored directly in your
code. There are various methods and packages available that are more
secure; this package does not require you to use any one in particular.
}
\examples{
\dontrun{
rev_user <- "my_username"
rev_pwd <- "super_secret"
product_ids_list <- c("123", "456", "789")
start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
end_date <- Sys.Date() - 1
session_id <- revenera_auth(rev_user, rev_pwd)
monthly_active_users <- get_active_users(
  product_ids_list,
  "month",
  start_date,
  end_date,
  session_id,
  rev_user
)
}

}
