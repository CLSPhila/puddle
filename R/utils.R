#' Internal Utilities

PUDDLE_TABLE_NAME <- "Datasets"
PUDDLE_SCHEMA <- c(
  "ID"="INTEGER PRIMARY KEY",
  "name"="TEXT",
  "data"="BLOB", # storing the data as a binary BLOB in the database.
  "description"="TEXT",
  "date_modified"="TEXT"
)



ensure_puddle_schema <- function(conn) {
  if (!DBI::dbExistsTable(conn,PUDDLE_TABLE_NAME)) {
    DBI::dbCreateTable(conn, PUDDLE_TABLE_NAME,PUDDLE_SCHEMA)  
  }
  return(conn)
}

insert_dataset <- function(puddle_db, raw_data, data_name, description) {
  
  
  statement = paste(
    "INSERT INTO", PUDDLE_TABLE_NAME, "(name, description, date_modified, data) ",
    "VALUES (:name, :desc, :date, :raw)"
  )
  res <- RSQLite::dbSendStatement(puddle_db,
                                  statement, 
                                  params=list(
                                    name=data_name, 
                                    desc=description,
                                    date=as.character(Sys.time()),
                                    raw=raw_data))
  RSQLite::dbClearResult(res)
}

update_dataset <- function(puddle_db, raw_data, data_name, description) {
  
  
  statement = paste(
    "UPDATE", PUDDLE_TABLE_NAME, 
    "SET description = :description, date_modified = :date, data = :raw_data", 
    "WHERE name = :name")
  
  res <- RSQLite::dbSendStatement(puddle_db,
                                  statement, 
                                  params=list(
                                    name=data_name, 
                                    description=description,
                                    date=as.character(Sys.time()),
                                    raw_data=raw_data))
  RSQLite::dbClearResult(res)
}

# not for exporting
store_dataset <- function(puddle_db, raw_data, data_name, description) { 
  metadata <- RSQLite::dbGetQuery(puddle_db, paste0('SELECT * from ', PUDDLE_TABLE_NAME, ' WHERE name=:n'), params=list(n=data_name))
  if(nrow(metadata)!=0) {
    # The dataset is already present (a matching unique name), so 
    # update rather than inserting.
    update_dataset(puddle_db, raw_data, data_name, description)
  } else {
    insert_dataset(puddle_db, raw_data, data_name, description)
  }
}

# not for exporting
get_stored_dataset <- function(puddle_db, data_name)  {
  metadata <- RSQLite::dbGetQuery(puddle_db, paste0('SELECT * from ', PUDDLE_TABLE_NAME, ' WHERE name=:n'), params=list(n=data_name))
  
  if(nrow(metadata)==0) {
    message("Dataset not in puddle. Need to fetch it.")
    return(NA)
  } else {
    message("Found the dataset. Returning it")
    return(metadata[1,"data"])
  }
}
