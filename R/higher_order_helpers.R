

#' Make a fetcher and reader function to fetch a particular report from LegalServer.
#'
#' Generate a pair of functions for fetching and reading legalserver data. 
#' This is just a shortcut, as this is a common thing to do with the puddle library.
#' Requires LegalServerReader library.
#' 
#' @export
#' 
mkLegalServerFunctions <- function(report_name, creds_path) {
  return(
    list(
      fetch = function() {
        tc <- textConnection("ser_report", "w")
        
        
        rpt <- LegalServerReader::get.report(
          LegalServerReader::get.credentials(creds_path), 
          report_name)
        
        write.csv(rpt, tc,row.names = F)
        close(tc)
        return(paste0(ser_report,collapse=""))
      },
      read = function(ser_data) {
        return(read.csv(text=ser_data))

      }
    )
  )
}