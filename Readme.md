# Puddle 

## A tiny data lake

## Get started right away

```R
devtools::install("https://github.com/clsphila/puddle")

# Define a couple functions.

# A function that can collect the data you want to use.
remote_data <- function() { 
  # collect data from an api somewhere and return it in a serialized format, like text ... 
  res <- httr::GET("https://raw.githubusercontent.com/CLSPhila/Puddle/main/inst/extdata/sample.csv")
  return(httr::content(res, as="text"))
}

# A function that can transform the serialized data into a dataframe.
deserialze_data <- function(serialized_data) { 
  # transform from the serialized output of `remote_data` to a dataframe
  read_text <- function(raw_data) {
  return(read.csv(text=raw_data,stringsAsFactors = FALSE))
}

# Get your data, collecting from the puddle if possible, or with the `remote_data` function if necessary.

# `puddle::scoop` will only call `remote.data` once, and store the results in a tiny data lake. 
# Subsequent times you run the script, `puddle::scoop` will use this cached copy of the data instead of 
# calling out to this other resource.  
mydata <- puddle::scoop(FETCH_FUN=remote.data, 
                        READ_FUN=deserialize_data, 
                        data_name="myinterestingdataset", 
                        description="A sample dataset for illustrating Puddle.", 
                        puddle="~/puddle/puddle.sqlite")

mydata %>%
    doSomeAnalysis()
```

`Puddle` helps to solve two problems. 

## Tables, Tables, Everywhere

When doing data analysis projects, I often need to collect data from a "source of truth", such as a database containing user records. client activity records, or other things. I can often only access the data by downloading csv files (or similar) to my local machine. This means I accumulate files of data in lots of different places. Frequently the data ends up in the working directory of the project, the Downloads folder, and could end up stashed anywhere else that was convenient at the time. Its impossible to keep track of it all or to make sure there _isn't_ data somewhere I don't need it to be anymore. (Like once a project is done). Having data files stored so willy-nilly is messy, and if there is anything confidential in a data file, it also becomes more difficult to protect the security of that information.

This `Puddle` library stores my data in a single configurable location, and also provides a convenient way to read the data into an R project. `Puddle` stores datasets in a Sqlite database, which you can also encrypt in various ways (search online for a mechanism that would work for you).

## Cache, Sometimes

It is helpful to readers when the code of an R project shows where the data really comes from. If the data is from "https://example.com/api", code describing an analysis of the data should include code to fetch that authoritative data, rather than a call to `read.csv("some/local/path.csv")`. 

But if a script directly calls an online resource, it can be easy to make too many calls to that resource. Every time a script runs, it will call the network resource. While creating an analysis, this practice can slow down other users of the resource. 

`Puddle`'s core function, `puddle::scoop`, takes a function as an argument called `FETCH_FUN`. When `FETCH_FUN` is evaluated, it fetches a dataset from, for example, the network. `scoop` also _stores_ the dataset in a database with information about when it was collected and other notes. Then the next time the code executes, `scoop` makes sure to return the cached data, rather than going back out to the network.

This way you can control when you call out to a network without having to edit your code. 

`scoop` has additional parameters to force refreshing a dataset, if you know you want to do so. 

## Installation

Currently, this package is in very early development and is not available on CRAN. So install, use `devtools::install_github('https://github.com/clsphila/puddle')`

## A Motivating Example: LegalServer Reports

I do much of my data analysis using data from an internal web app called "LegalServer". To get data from Legalserver, I need to either download a file (xlsx or csv) or call an api. The API returns xml, but there's already an R library [LegalServerReader](https://github.com/CLSPhila/LegalServerReader) for tranforming the xml into a dataframe. 

One limitation of the API is that I don't want to download the same data over and over, because that would put an unacceptable load on a server that has better things to do. But I also don't want to rely solely on downloading csv files for my data analysis for the reasons discussed above.

With `Puddle`, I can use `LegalServerReader` to download the data I need and cache it. My analysis code is clear about where the data comes from, but also doesn't re-download the data every time I run the code. 

```r
# This fetch function downloads the data from the api, and serialized it to text.
fetch_report <- function() {
  tc <- textConnection("ser_report", "w")
  
  
  rpt <- get.credentials(".creds") %>%
    get.report("API - Intakes")
  
  write.csv(rpt, tc,row.names = F)
  close(tc)
  return(paste0(ser_report,collapse=""))
}

read_report <- function(ser_report) {
  return(read.csv(text=ser_report))
}

intakes <- puddle::scoop(fetch_report, read_report, "API - Intakes", "Intakes today.", puddle="puddle.sqlite")

# Lets look into our puddle to see that we've got the legalserver data.
get_puddle_connection("puddle.sqlite") %>% gaze
```

You can write the `fetch` and `read` functions to serialize the data any way you like. For example instead of serializing to a string of text, you could serialize to a binary format like with `feather.`. 


