



#' Fetch a dataset from the puddle, or if its not present, fetch the dataset 
#' from elsewhere, store it in the puddle, and then pass it along to you.
#' 
#' @param FETCH_FUN A zero-argument function that fetches raw data, such as a csv file, xml, or json, and returns it.
#' @param READ_FUN A one-argument function that takes the raw data of FETCH_FUN and returns a dataframe. For example, read.csv, 
#'   or function(text) {read.csv(text, stringsAsFactors=F)}
#' @param data_name A name for the dataset in the puddle. Must be unique in the puddle. 
#' @param description Descriptive text about the dataset.
#' @param renew Should `scoop` run FETCH_FUN, even if the data is already in the the puddle, and store the new version?
#' @param puddle A string for connecting to the sqlite puddle database. Defaults to ':memory:', which is only really useful for demonstration. 
#' 
#' FETCH_FUN and READ_FUN are complementary. They can be whatever you want, so long as the composition, 
#' READ_FUN( FETCH_FUN() ) returns your dataset as a dataframe.
#' 
#' @export
scoop <- function(FETCH_FUN, READ_FUN, data_name, description, renew=FALSE, puddle=":memory:") {

  #Find the puddle that's been configured. It may be sent explitly as a param here,
  # or as an ENV var.
  puddle_db <- get_puddle_connection(puddle)
  
  if (renew == FALSE) {
    raw_data <- get_stored_dataset(puddle_db, data_name)
  } else {
    raw_data <- NA
  }
  if (is.na(raw_data)) {
    raw_data <- FETCH_FUN()
    store_dataset(puddle_db, raw_data, data_name, description)
  }
  DBI::dbDisconnect(puddle_db)
  return(READ_FUN(raw_data))
}


