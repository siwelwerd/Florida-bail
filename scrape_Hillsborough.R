# Load libraries
library(tidyverse)
library(lubridate)
library(selenider)
library(rvest)

# Open selenium session
session <- selenider_session("selenium",browser="chrome")

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

fileName = "Hillsborough counts.csv"

startDate <- ymd("2020-01-01")
endDate <- ymd("2024-12-31")


#Check for file from aborted past run, and adjust date to pickup
#where we left off if needed
if( file.exists(fileName) )
{
  df <- read_table(fileName)
  lastDate <- df %>% tail(n=1) %>% {.[[1,1]]} %>% ymd()
  if(lastDate > startDate)
  {
    startDate <- lastDate + 1
    print(paste("Resuming from ",lastDate))
  }
  if(lastDate == endDate)
  {
    print(paste("There were", sum(df$cases), "total cases between ", df[[1,1]], "and",endDate)) 
    quit()
  }
} else
{
  df <- tibble(date= Date(), cases=numeric())
}

#Loop over dates in range, we will fetch one day at a time
for (d in as.list(seq(startDate,endDate,as.difftime(days(1)))))
{
  print(d)
  
  #Initial waiting period before retrying
  cooloff=2
  #Wrap in a while loop so we can retry  the same date if it errors out
  while(TRUE){
  # Navigate to page
  open_url("https://hover.hillsclerk.com/html/case/caseSearch.html#nav-DateFiled-tab")
  
  #Add some sleepy time to maybe reduce errors
  Sys.sleep(cooloff)
  
  # Select Criminal cases from dropdown
  Sys.sleep(1)
  session %>% 
    find_element(class_name="caseCategoryClass") %>%
    elem_expect(is_present) %>%
    elem_select(text="CRIMINAL")
  
  Sys.sleep(1.5)
  session %>%
    find_element(class_name="caseTypesClass") %>%
    elem_select(text=caseTypes)
  
  # Need to set dates... date picker gets in the way.
  #Attempt to set value to get datepicker to show up
  session %>% 
    find_element(id="dateFiledAfter") %>%
    elem_set_value("01/01/2020")
  #Select Year
  session %>%
    find_elements(class="ui-datepicker-year") %>%
    {.[[1]]} %>%
    elem_select(year(d))
  #Select Month
  session %>%
    find_elements(class="ui-datepicker-month") %>%
    {.[[1]]} %>%
    elem_select(month(d)-1)
  #Select Day
  session %>%
    find_elements(class="ui-state-default") %>%
    {.[[mday(d)]]} %>%
    elem_click()
  
  #Attempt to set value to get datepicker to show up
  session %>% 
    find_element(id="dateFiledBefore") %>%
    elem_set_value("01/01/2020")
  #Set Year
  session %>%
    find_elements(class="ui-datepicker-year") %>%
    {.[[1]]} %>%
    elem_select(year(d))
  #Set Month
  session %>%
    find_elements(class="ui-datepicker-month") %>%
    {.[[1]]} %>%
    elem_select(as.character(month(d)-1))
  #Set Day
  session %>%
    find_elements(class="ui-state-default") %>%
    {.[[mday(d)]]} %>%
    elem_click()
  
  #Click search button
  session %>%
    find_element(id="btnSubmitDateFiledSearch") %>%
    elem_scroll_to() %>%
    elem_click()
  

  

  #Each case is in a table row, so pull those out,
  #But make sure we wait for it to load.
  #We get an empty table row while loading, so wait for length to be
  #more than 2
  #This keeps erroring, so wrap it in a try
  t <- try(session |>
    find_element(id="mycasesdata") %>%
    find_element("tbody") %>%
    find_elements("tr") %>%
    elem_expect(
    \(elem) elem |>
      length() >2 
    ,timeout=10) 
  )
  if(!inherits(t,'try-error'))
  {
    break
  } else
  {
    #Wait for a bit and then try again.  Increment wait time each attempt
    print(paste("Error on ",d, " trying again"))
    Sys.sleep(2)
    #Sometimes this fails too, so wrap it in a try
    try(close_session())
    Sys.sleep(cooloff)
    session <- selenider_session("selenium",browser="chrome")
    cooloff <- cooloff+30
    next
  }
  }
  
  caseCount <- length(t)
  
  print(paste("There were", caseCount, "cases on", d))
  df <- df %>% add_row(date=d,cases=caseCount)
  df %>% write.table(file=fileName,row.names=FALSE,quote=FALSE)
  
}

print(paste("There were", sum(df$cases), "total cases."))

