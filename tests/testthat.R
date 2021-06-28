library(testthat)
library(puddle)

test_check("puddle")


context("Puddle data caching")

remote_data <- function() { 
  # collect data from an api somewhere and return it in a serialized format, like text ... 
  res <- httr::GET("https://raw.githubusercontent.com/CLSPhila/Puddle/main/inst/extdata/sample.csv")
  return(httr::content(res, as="text"))
}

deserialize_data <- function(serialized_data) { 
  # transform from the serialized output of `remote_data` to a dataframe
  return(read.csv(text=serialized_data,stringsAsFactors = FALSE))
}
  

test_that("drip stores a dataset is not in the puddle", {
  pdb <- puddle::get_puddle_connection(":memory:")
  pdb <- puddle::drip(pdb, remote_data, "sample", "some sample data")
  contents <- gaze(pdb)
  expect_equal(nrow(contents),1)
})

test_that("drip only stores a dataset once", {
  pdb <- puddle::get_puddle_connection(":memory:")
  pdb <- puddle::drip(pdb, remote_data, "sample", "some sample data")
  contents <- gaze(pdb)
  expect_equal(nrow(contents),1)
  
  pdb <- puddle::drip(pdb, remote_data, "sample", "some sample data")
  contents_modified <- gaze(pdb)
  expect_equal(nrow(contents_modified),1)
})


test_that("scoop stores and fetches a dataset", {
  res <- scoop(remote_data, deserialize_data, "sample data", "some data", puddle=":memory:")
  expect_equal(ncol(res), 2)
})

