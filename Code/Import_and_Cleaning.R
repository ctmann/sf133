
# Header ------------------------------------------------------------------
#' Compile SF133, an OMB Budget execution report
#' Excel files for Department of Defense-Military



# Libraries -------------------------------------------------
library(tidyverse)
library(readxl)
library(arsenal)

# Functions and Common Vars -----------------------------------------------


# How to Update this file -------------------------------------------------

# Step 1
current.fy <- 2018

#Step 2
# manual; paste new hyperlink in sf.tibble, below. Unfortunately, no predictable pattern.

# Import ------------------------------------------------------------------
#' 1. Create a tibble with hyperlinks
#' 2. Download data to tibble:  (downloading directly with read_excel is not currently possible)
#' 3. unnest

# 1. Create tibble
      sf.tibble <- tibble(
        report.FY = c(2013:current.fy),
        my.filename = paste0("./Data/Raw/", report.FY, ".xlsx"),
        hyperlink = c("https://portal.max.gov/portal/document/SF133/Budget/attachments/646122715/660638471.xlsx",     #FY2013
                      "https://portal.max.gov/portal/document/SF133/Budget/attachments/703038966/737052130.xlsx",     #FY2014
                      "https://portal.max.gov/portal/document/SF133/Budget/attachments/781353958/783221158.xlsx",     #FY2015
                      "https://portal.max.gov/portal/document/SF133/Budget/attachments/984121454/984056306.xlsx",     #FY2016
                      "https://portal.max.gov/portal/document/SF133/Budget/attachments/1186759944/1187284005.xlsx",   #FY2017
                      "https://portal.max.gov/portal/document/SF133/Budget/attachments/1375242472/1516309877.xlsx"    #FY2018
                          #< new hyperlink goes here #
                      ))

# 2.  Download and Read

      # Download Excel Files to Raw folder
      my.download.function <- function(my.url,my.download.filename){
        download.file(my.url, my.download.filename, mode = "wb")}
      
      Map(my.download.function, sf.tibble$hyperlink, sf.tibble$my.filename)
      
      
      # Read files to tibble
      sf.tibble.2 <- sf.tibble %>% 
        mutate(my.data = map(my.filename, ~(.x %>% 
                                              read_excel(sheet="Raw Data", col_types="text") ) ) )
                                      

# 3.  Unnest and initial tidy
      sf.tibble.3 <- sf.tibble.2 %>% 
        unnest() %>% 
        group_by(report.FY) %>% 
        mutate(sorting.id = row_number() ) %>% 
        select(sorting.id, everything())

View(sf.tibble.3)







x.2017 <- sf.tibble.2 %>% filter(report.FY %in% "2018") %>% unnest()
x.2018 <- sf.tibble.2 %>% filter(report.FY %in% "2017") %>% unnest()

setdiff(names(x.2017), names(x.2018) )

compare(x.2017, x.2018)

# download to temp file
tmp <- tempfile(fileext = ".xlsx")

# download one
sf.tibble$hyperlink[1:2]


httr::GET(url = sf.tibble$hyperlink[1:2],
            write_disk( tmp) )

excel_sheets(path=tmp)
read_excel(path=tmp, sheet="Raw Data", col_types="text")




