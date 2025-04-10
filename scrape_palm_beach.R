# Load libraries
library(tidyverse)
library(janitor)
library(selenider)
library(rvest)

# Open selenium session
session <- selenider_session("selenium",browser="chrome")

# Navigate to page
open_url("https://appsgp.mypalmbeachclerk.com/eCaseView")

# Locate the button and click it
session |>
  find_element("#cphBody_ibGuest") |>
  elem_click()

# Go to browser window and solve CAPTCHA by hand
session |> elem_wait_until("#cphBody_gvSearch_cmbParameterNoPostBack_1", timeout = 30)

# Set search parameters
lastInit <- "A"
firstInit <- "A"
startFile <- "01/01/2020"
endFile <- "06/30/2020"
courtType <- "8"

# Select "Starts With Name Search" from the dropdown
session |>
  find_element("#cphBody_gvSearch_cmbParameterNoPostBack_1") |>
  elem_set_value("97")

Sys.sleep(0.5)

# Fill in last name
session |>
  find_element("#cphBody_gvSearch_txtParameter_2") |>
  elem_clear_value() |>
  elem_send_keys(lastInit)

# Fill in first name
session |>
  find_element("#cphBody_gvSearch_txtParameter_3") |>
  elem_clear_value() |>
  elem_send_keys(firstInit)

# Select Court Type from the dropdown
session |>
  find_element("#cphBody_gvSearch_cmbParameterPostBack_5") |>
  elem_set_value(courtType)

Sys.sleep(2)

# Enter start file date
session |>
  find_element("#cphBody_gvSearch_txtParameter_10") |>
  elem_clear_value() |>
  elem_send_keys(startFile)

# Enter end file date
session |>
  find_element("#cphBody_gvSearch_txtParameter_11") |>
  elem_clear_value() |>
  elem_send_keys(endFile)

# Locate the Search button and click it
session |>
  find_element("#cphBody_cmdSearch") |>
  elem_click()

# Wait a couple of seconds to load
Sys.sleep(3)


# Read page source and parse, extract table info
results <-  session %>% get_page_source()  %>%
  html_table %>%
  {.[[1]]} %>% {.[-(1:2),]} %>% row_to_names(row_number = 1) %>%
  select(docket = `Case Number`,
         courtType = `Court Type`,
         caseType = `Case Type`,
         arrestDate = `Arrest Date`,
         fileDate = `File Date`,
         name = `Case Style`,
         status = `Status`)

print(results)
