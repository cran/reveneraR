% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_client_metadata.R
\name{get_client_metadata}
\alias{get_client_metadata}
\title{Get Metadata on Client Ids for a List of Product Ids}
\usage{
get_client_metadata(
  rev_product_ids,
  rev_session_id,
  rev_username,
  product_properties_df,
  desired_properties,
  installed_start_date,
  installed_end_date,
  chatty = FALSE
)
}
\arguments{
\item{rev_product_ids}{A vector of Revenera product id's for which
you want active user data.}

\item{rev_session_id}{Session ID established by the connection to
Revenera API. This can be obtained with revenera_auth().}

\item{rev_username}{Revenera username.}

\item{product_properties_df}{Data frame with available properties
for all product ids. Can obtain with the get_product_properties function.}

\item{desired_properties}{The property names of the metadata you want
to collect.}

\item{installed_start_date}{Date object for the starting date of
product installations.}

\item{installed_end_date}{Date object for the ending date of
product installations.}

\item{chatty}{The function can be chatty, sending a message to the console
for every iteration through a product Id. Many API calls may be required
and the console may get very long and it may slow down the execution.}
}
\value{
Data frame with selected properties for each Client Id.
}
\description{
Returns metadata (what Revenera calls "properties") for every
Client Id installed during user-provided date range for all product
Ids in a list.
}
\details{
It is not recommended that your username be stored directly in your
code. There are various methods and packages available that are more
secure; this package does not require you to use any one in particular.

This API call can only return 200 Client Ids at a time. It will take a
long time to execute if you have many Client Ids, as the function will
submit requests to the API repeatedly; this may even result in a timeout
error from the server. In order to provide data for troubleshooting
this function will write a message to the console after each call.
It is recommended that you divert the console output to a text file.
You can do this in multiple ways, including with the sink function (see
example for how to do this).

For the same reason you are encouraged to break your request into
smaller chunks using the install dates and/or splitting up your
product Ids.
}
\examples{
\dontrun{
rev_user <- "my_username"
rev_pwd <- "super_secret"
product_ids_list <- c("123", "456", "789")
session_id <- revenera_auth(rev_user, rev_pwd)
product_properties <- get_product_properties(
  product_ids_list, session_id,
  rev_user
)
sink("output_filename.txt")
sink(stdout(), type = "message")
client_metadata <- get_client_metadata(
  product_ids_list, session_id,
  rev_user, product_properties, c("Property1", "Property2"),
  start_date, end_date
)
sink()
}

}
