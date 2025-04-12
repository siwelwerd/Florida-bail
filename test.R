library(selenider)
library(rvest)
library(tidyverse)
library(lubridate)


#session <- selenider_session("selenium",browser="chrome")
#open_url("https://appsgp.mypalmbeachclerk.com/eCaseView")
#
#rv <- session |> get_page_source() |> html_table() 
#print(rv[[1]])


startDate = ymd("2020-03-25")
endDate = ymd("2020-04-03")
dates = as.list(seq(startDate,endDate,as.difftime(days(1))))


df <- read_table("Hillsborough counts.csv")
for (d in dates)
{
  #print(d)
  #df <- df %>% add_row(date=format_ISO8601(d),cases=10)
}

print(df)
last_date <- df %>% tail(n=1) %>% {.[[1,1]]}
print(last_date)
if (ymd(last_date) > startDate)
{
  print ("Yes1")
}
if (ymd(last_date) > endDate)
{
  print ("Yes2")
}