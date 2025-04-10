# Load libraries
library(tidyverse)
library(selenider)
library(rvest)

# Open selenium session
session <- selenider_session("selenium",browser="chrome")

# Navigate to page
open_url("https://hover.hillsclerk.com/html/case/caseSearch.html#nav-DateFiled-tab")

Sys.sleep(2)
# Select Criminal cases from dropdown
# Select "Starts With Name Search" from the dropdown
#session |>
#  find_element("caseCategory") |>
#  elem_set_value("CR")

elements <- session |> find_elements(class_name="caseCategoryClass")

print(elements[[1]])


session %>% 
  find_elements(class_name="caseCategoryClass") %>%
  {.[[1]]} %>%
  elem_select(text="CRIMINAL")

Sys.sleep(0.5)

caseTypes <- c("FELONY ADDENDUM", 
  "FELONY ADMINISTRATIVE CASE",
  "FELONY BOND FORFEITURE",
  "FELONY BURGLARY",
  "FELONY CAPITAL MURDER",
  "FELONY CAPITAL SEXUAL BATTERY",
  "FELONY CONSOLIDATED CASE",
  "FELONY CRIMES AGAINST A PERSON",
  "FELONY CRIMES AGAINST PROPERTY",
  "FELONY DRUG OFFENSE",
  "FELONY FUGITIVE",
  "FELONY INTERSTATE COMPACT AGREEMENT",
  "FELONY NON CAPITAL MURDER",
  "FELONY OTHER FELONY",
  "FELONY RICO",
  "FELONY ROBBERY",
  "FELONY SEXUAL OFFENSES",
  "FELONY THEFT FORGERY FRAUD",
  "FELONY WITNESS OUT OF STATE",
  "FELONY WORTHLESS CHECK",
  "MISDEMEANOR",
  "MISDEMEANOR WORTHLESS CHECK",
  "MISDEMEANOR NON CRIMINAL INFRACTIONS",
  "MISDEMEANOR ORDINANCE VIOLATIONS")

session %>%
  find_elements(class_name="caseTypesClass") %>%
  {.[[1]]} %>%
  elem_select(text=caseTypes)

# Need to get dates... date picker gets in the way.
#session %>% 
#  find_element(id="dateFiledBefore") %>%
#  elem_set_value("01/01/2020")

Sys.sleep(5)

#source <- session |> get_page_source()

#print(source %>% xml_structure())