
# Header ------------------------------------------------------------------
#' Compile SF133, an OMB Budget execution report
#' Excel files for Department of Defense-Military



# Libraries -------------------------------------------------
library(tidyverse)
library(readxl)
library(arsenal)
library(stringr)
library(rpivotTable)

# Functions and Common Vars -----------------------------------------------
  iferror <- function(expr, error_expr){
  tryCatch(expr, error=function(e){error_expr})
}     
      


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
        select(sorting.id, everything()) %>% ungroup()

      # Remove (some) inconsistent columns
      sf.tibble.4 <- sf.tibble.3 %>% 
        select(-c(#ALLOC,
                  COHORT,
                  CAT_B) ) 
      # NAs expose inconsistent formatting
        # sf.tibble.4 %>% summarise_all(funs(sum(is.na(.)) )) %>% View()
      
# Basic Tidying ----------------------------------------------------------------

      # Convert and Trim
      sf.tibble.5 <- sf.tibble.4 %>% 
        # Trim strings
        mutate_if(is.character, str_trim) %>% 
        # convert numbers
        mutate_at(vars(contains(match="AMT")), funs(parse_number) ) %>% 
        # convert dates
        mutate(LAST_UPDATED = parse_date(LAST_UPDATED, "%Y-%m-%d") )
      
      
# Add Metadata ------------------------------------------------------------
#' 1 account.name
#' 2 service
#' 3 ac.rc
#' 4 life.FY.begin
#' 5 life.FY.end
#' 6 life.of.money
#' 7 lifespan.of.money
#' 8 FY.cancelled.calculated

      # 1,2: Account name and service
      sf.tibble.6 <- sf.tibble.5 %>% 
        mutate(
          account.name = str_sub(OMB_ACCT, start=15),
          service = case_when(
              #TRAG 12 is not Dept. of Agriculture; TRAG 69 is not Dept.Transportation
              TRAG %in% "12"| TRAG %in% "21" | str_detect(account.name, "Army") | ALLOC %in% "21"          ~ "Army",
              str_detect(account.name, "Marine Corps") & !str_detect(account.name, "Navy")                 ~ "Marine.Corps",
              TRAG %in% "17" | ALLOC %in% "17" | str_detect(account.name, "Navy")                          ~ "Navy",
              TRAG %in% "57" | ALLOC %in% "57" | str_detect(account.name, "Air Force")                     ~ "Air.Force",
              TRAG %in% "97" | ALLOC %in% "97" | str_detect(account.name, "Defense-Wide")                  ~ "Defense.Wide",
              TRUE                                                                                         ~ "unknown"
              ) ) 

    # 3. ac.or.rc  
    sf.tibble.7 <- sf.tibble.6 %>% 
      mutate(ac.rc = case_when(
        service %in% c("Army", "Marine.Corps", "Navy", "Air.Force") & 
          (str_detect(OMB_ACCOUNT, "Reserve")|str_detect(OMB_ACCOUNT, "National Gu") ) ~ "RC",
        service %in% c("Army", "Marine.Corps", "Navy", "Air.Force")              ~ "AC",
        TRUE ~ "Other") ) 
            
   # 4,5,
     sf.tibble.8 <-  sf.tibble.7 %>% 
        mutate(
            # Helper life cols
          helper.FY.begin = ifelse(!is.na(FY1), 
                                   FY1,  
                                   FY2), 
          helper.FY.end   = FY2,
            # life.begin
          life.FY.begin = case_when(
            str_detect(helper.FY.begin, "X")      ~ helper.FY.begin,
            parse_number(helper.FY.begin) >= 50   ~  paste0("19",  helper.FY.begin),
            parse_number(helper.FY.begin) <  50   ~  paste0("20",  helper.FY.begin)) ,
            # life.end
          life.FY.end = case_when(
            str_detect(helper.FY.end, "X")      ~ "X",
            parse_number(helper.FY.end) >= 50   ~  paste0("19",  helper.FY.end),
            parse_number(helper.FY.end) <  50   ~  paste0("20",  helper.FY.end))
          ) %>%  
       mutate(life.of.money = iferror(parse_number(helper.FY.end) - parse_number(helper.FY.begin)+1, helper.FY.end )) %>% 
       mutate(lifespan.of.money = paste0(life.FY.begin, "/", life.FY.end) ) %>% 
       mutate(FY.cancelled = iferror(parse_number(life.FY.begin) +5, "X") )
       

# export ------------------------------------------------------------------

     



