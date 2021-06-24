#' Get a connection the puddle's SQLite database.
#' 
#' @export
#' @param puddle SQLite connection string to connect to (or create) a puddle database.
get_puddle_connection <- function(puddle) {
  
  
  conn <- DBI::dbConnect(RSQLite::SQLite(), puddle)
  
  # Make sure the schema is right. One table called 'Datasets' with 
  # columns ID, 
  puddle_db <- ensure_puddle_schema(conn)
  return(puddle_db)
}
