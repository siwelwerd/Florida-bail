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
session %>% 
  find_elements(class_name="caseCategoryClass") %>%
  {.[[1]]} %>%
  elem_select(text="CRIMINAL")

Sys.sleep(0.5)

#Select Felonies and Misdemeanors
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
#Attempt to set value to get datepicker to show up
session %>% 
  find_element(id="dateFiledAfter") %>%
  elem_set_value("01/01/2020")
#Year
session %>%
  find_elements(class="ui-datepicker-year") %>%
  {.[[1]]} %>%
  elem_select("2020")
#Month
session %>%
  find_elements(class="ui-datepicker-month") %>%
  {.[[1]]} %>%
  elem_select("0")
#Day
session %>%
  find_elements(class="ui-state-default") %>%
  {.[[1]]} %>%
  elem_click()

#Attempt to set value to get datepicker to show up
session %>% 
  find_element(id="dateFiledBefore") %>%
  elem_set_value("01/01/2020")
#Year
session %>%
  find_elements(class="ui-datepicker-year") %>%
  {.[[1]]} %>%
  elem_select("2020")
#Month
session %>%
  find_elements(class="ui-datepicker-month") %>%
  {.[[1]]} %>%
  elem_select("0")
#Day
session %>%
  find_elements(class="ui-state-default") %>%
  {.[[1]]} %>%
  elem_click()

#Click search button
session %>%
  find_element(id="btnSubmitDateFiledSearch") %>%
  elem_scroll_to() %>%
  elem_click()


Sys.sleep(10)

t <- session |>
  find_element(id="mycasesdata") %>%
  find_element("tbody") %>%
  find_elements("tr")
#
#children <- t |> elem_children()
#
print(t)

#source <- session |> get_page_source()

#print(source %>% xml_structure())