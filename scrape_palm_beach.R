# Load libraries
library(tidyverse)
library(janitor)
library(selenider)
library(rvest)

# Helper function
#cleanup_selenium <- function() {
# log_info("Cleaning Selenium processes...")
# if (.Platform$OS.type == "windows") {
#    system("taskkill /F /IM geckodriver.exe /T", ignore.stderr = TRUE, ignore.stdout = TRUE)
#    system("taskkill /F /IM firefox.exe /T", ignore.stderr = TRUE, ignore.stdout = TRUE)
#  } else {
#    system("pkill -f geckodriver", ignore.stderr = TRUE, ignore.stdout = TRUE)
#    system("pkill -f firefox", ignore.stderr = TRUE, ignore.stdout = TRUE)
#  }
#  Sys.sleep(0.5)  # Slightly shorter than 1s
#}

# Another helper function
# Function to wait for an element to appear
#wait_for_element <- function(css_selector, timeout = 60, poll_interval = 1) {
#  start_time <- Sys.time()
#  while (as.numeric(Sys.time() - start_time, units = "secs") < timeout) {
#    element <- tryCatch({
#      remDr$findElement(using = "css selector", value = css_selector)
#    }, error = function(e) NULL)
#    
#    if (!is.null(element)) {
#      message("Element found: proceeding.")
#      return(TRUE)
#    }
#    
#    Sys.sleep(poll_interval)
#  }
#  stop(paste("Timed out waiting for element:", css_selector))
#}

# Set up selenium
#cleanup_selenium()
#rD <- rsDriver(browser = "firefox", version = "latest", geckover = "latest")
session <- selenider_session("selenium",browser="chrome")
#remDr <- rD$client

# Navigate to page
#remDr$navigate("https://appsgp.mypalmbeachclerk.com/eCaseView")
open_url("https://appsgp.mypalmbeachclerk.com/eCaseView")

# Locate the button by CSS selector and click it
#guest_button <- remDr$findElement(using = "css selector", value = "#cphBody_ibGuest")
#guest_button$clickElement()

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
#searchDropdown <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_cmbParameterNoPostBack_1")
#searchDropdown$sendKeysToElement(list("Starts With Name Search"))
session |>
  find_element("#cphBody_gvSearch_cmbParameterNoPostBack_1") |>
  elem_set_value("97")

Sys.sleep(0.5)

# Fill in last name
#last_name_input <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_txtParameter_2")
#last_name_input$clearElement()
#last_name_input$sendKeysToElement(list(lastInit))

session |>
  find_element("#cphBody_gvSearch_txtParameter_2") |>
  elem_clear_value() |>
  elem_send_keys(lastInit)

# Fill in first name
#first_name_input <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_txtParameter_3")
#first_name_input$clearElement()
#first_name_input$sendKeysToElement(list(firstInit))

session |>
  find_element("#cphBody_gvSearch_txtParameter_3") |>
  elem_clear_value() |>
  elem_send_keys(firstInit)

# Select Court Type from the dropdown
#courtDropdown <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_cmbParameterPostBack_5")
#courtDropdown$sendKeysToElement(list(courtType))

session |>
  find_element("#cphBody_gvSearch_cmbParameterPostBack_5") |>
  elem_set_value(courtType)

Sys.sleep(2)

# Enter start file date
#start_input <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_txtParameter_10")
#start_input$clearElement()
#start_input$sendKeysToElement(list(startFile))

session |>
  find_element("#cphBody_gvSearch_txtParameter_10") |>
  elem_clear_value() |>
  elem_send_keys(startFile)

# Enter end file date
#end_input <- remDr$findElement(using = "css selector", "#cphBody_gvSearch_txtParameter_11")
#end_input$clearElement()
#end_input$sendKeysToElement(list(endFile))

session |>
  find_element("#cphBody_gvSearch_txtParameter_11") |>
  elem_clear_value() |>
  elem_send_keys(endFile)

# Locate the Search button and click it
#search_button <- remDr$findElement(using = "css selector", value = "#cphBody_cmdSearch")
#search_button$clickElement()

session |>
  find_element("#cphBody_cmdSearch") |>
  elem_click()

# Wait a couple of seconds to load
Sys.sleep(3)

# Set the dropdown menu for results shown to show all on one page
#resultsDropdown <- remDr$findElement(using = "css selector", "#cphBody_cmbPageSize")
#resultsDropdown$sendKeysToElement(list("All"))

#session |>
#  find_element("#cphBody_cmbPageSize") |>
#  elem_send_keys("All")

Sys.sleep(1)

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
