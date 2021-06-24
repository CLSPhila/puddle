#' Add a dataset to a puddle.
#' 
#' @export
#' 
#' @param puddle_db A connection to a puddle sqlite database.
#' @param FETCH_FUN A zero-argument function that fetches raw data, such as a csv file, xml, or json, and returns it.
#' @param data_name A name for the dataset in the puddle. Must be unique in the puddle. 
#' @param description Descriptive text about the dataset.
#' @return The puddle_db connection, ready for thenext thing you want to do. 
drip <- function(puddle_db, FETCH_FUN, data_name, description) {
  raw_data <- FETCH_FUN()
  store_dataset(puddle_db, raw_data, data_name, description)
  return(puddle_db)
}