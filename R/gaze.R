
#' Gaze into the puddle datasets
#' 
#' Review all the datasets in a particular puddle.
#' 
#' @export
#' @param puddle_db A connection to a puddle database.
gaze <- function(puddle_db) {
  return(RSQLite::dbGetQuery(puddle_db,paste("SELECT name, description, date_modified FROM", PUDDLE_TABLE_NAME)))
}
