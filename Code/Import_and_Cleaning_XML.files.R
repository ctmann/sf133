
# Header ------------------------------------------------------------------
#' Compile SF133, an OMB Budget execution report
#' Excel files for Department of Defense-Military
#' 
#' XML data is monthly, unlike excel docs, however,
#' XML colnames different.

# Libraries -------------------------------------------------
library(tidyverse)
library(readxl)
library(stringr)
library(rpivotTable)
library(feather)
library(janitor)

# Functions and Common Vars -----------------------------------------------
iferror <- function(expr, error_expr){
  tryCatch(expr, error=function(e){error_expr})
}     


# How to Update this file -------------------------------------------------

# Step 1
current.fy <- "2018"


# Import ------------------------------------------------------------------
#' 1. Create a tibble 
#' 2. read data to tibble:  (downloading directly with read_excel is not currently possible)
#' 3. unnest

# 1. Create tibble
xml.tibble.1 <- tibble(
  report.FY = 2014:current.fy,
  my.filename = paste0("./Data/Raw/xml/", 2014:current.fy, ".xlsx")
  )

# 2. Read files to tibble
xml.tibble.2  <- xml.tibble.1  %>% 
  mutate(my.data = map(my.filename, ~(.x %>% 
                                        read_excel(sheet="Raw", col_types="text") ) ) )
# 2. Read files to tibble
xml.tibble.3 <- xml.tibble.2 %>% 
  unnest() %>% 
  select(-my.filename) %>% 
  clean_names()
  
# Basic Tidying ----------------------------------------------------------------

xml.tibble.4 <- xml.tibble.3 %>% 
  #trim all
  mutate_if(is.character, str_trim) %>% 
  # convert numeric col, adj. for thousands
  mutate_at(vars(contains(match="amount")), funs(parse_number)) %>% 
  mutate(   amount = amount * 1e3) %>% 
   # pad bureau code id to 2
  mutate(budget_bureau_code = str_pad(`budget_account_id`, width = 2, side = "left", pad = 0) ) %>% 
  # pad account id to 4
  mutate(`budget-account_id` = str_pad(`budget_account_id`, width = 4, side = "left", pad = 0) ) %>%
  # pad account id to 4
  mutate(treasury_account_code = str_pad(`budget_account_id`, width = 4, side = "left", pad = 0) ) %>%
   # begin/end of life cols
  mutate(life.FY.begin = `cgac_beginning_poa_code`, life.FY.end = `cgac_ending_poa_code`) %>% 
  # no year money (yes/no)
  mutate(is.this.no.year.money = ifelse(`cgac_availability_type_code` %in% "X", "yes", "no") ) %>% 
  # rename to logical
  mutate(`month_number` = name3 %in% month.abb ) %>% 
  rename( fy1 = `fy1_code`, fy2 = `fy2_code`,
          section_name = name, section_number = number,
          line_type = type,
          line_number = number2, line_description = description,
          `month_abrev` = name3,
          status.expired.or.unexpired = tafs_status)

#Adding new cols
xml.tibble.5 <- xml.tibble.4 %>%    
  mutate(service = case_when(
  #Problem: Multiple agency code (treasury, cgac, allocation); code for 12 is  Dept. of Agriculture; code 69 is  Dept.Transportation??!!
  treasury_agency_code %in% "12"| str_detect(budget_account_title, "Army")                     ~ "Army",
  str_detect(budget_account_title, "Marine Corps") & !str_detect(budget_account_title, "Navy") ~ "Marine.Corps",
  treasury_agency_code %in% "17" | str_detect(budget_account_title, "Navy")                            ~ "Navy",
  treasury_agency_code %in% "57" | str_detect(budget_account_title, "Air Force")                       ~ "Air.Force",
  treasury_agency_code %in% "97" | str_detect(budget_account_title, "Defense-Wide")                    ~ "Defense.Wide",
  TRUE                                                                                         ~ "unknown") )  %>% 
  # active or reserve (best guess)
  mutate(ac.rc = case_when(
    service %in% c("Army", "Marine.Corps", "Navy", "Air.Force") & 
      (str_detect(budget_account_title, "Reserve")|str_detect(budget_account_title, "National Gu") ) ~ "RC",
    service %in% c("Army", "Marine.Corps", "Navy", "Air.Force")              ~ "AC",
    TRUE ~ "Other") ) %>% 
  mutate(life.of.money = iferror(parse_number(life.FY.end) - parse_number(life.FY.end)+1, life.FY.end )) %>% 
  mutate(lifespan.of.money = paste0(life.FY.begin, "/", life.FY.end) ) %>% 
  mutate(FY.cancelled = iferror(parse_number(life.FY.begin) +5, "X") ) 

# Merge other Enriching data -------------------------------------------------------
#' 1. Merge Public Law title (can't remember where I got this datasset)
#' 2. Merge include.exclude analysis (accounts identified by other analysts)

# Import refs data stored as tibbles
source(file="./Data/Raw/refs.R")

# 1: Public Law 
xml.tibble.6 <- xml.tibble.5 %>% 
  left_join(ref.pl, by = c("treasury_account_code" =  "account.code") )

#Check
dim(xml.tibble.5)
dim(xml.tibble.6)

# 2. Include.exclude.analysis
xml.tibble.7 <- xml.tibble.6 %>% 
  left_join(ref.include.exclude.analysis, by = c("treasury_account_code" = "account.code") )

#Check
dim(xml.tibble.6)
dim(xml.tibble.7)

final.xml.tibble <- xml.tibble.7


# Export ------------------------------------------------------------------

# Create a dbase with favorite lines
favorite.lines <- c(
  "1100",                         # APPN
  "2490", "2412", "2413",         # Unobligated, expired and unexpired
  "1029",                         # cancelled (DOD report)
  "1910", "2190", "3050", "4020") # 1002 lines

final.xml.tibble %>% 
  filter(line_number %in% favorite.lines) %>% 
  write_csv(paste0("./Data/Processed/xml.version_sf133_Compiled.with.fav.lines_2014.to.", current.fy ,".csv") )












