library(selenider)
library(rvest)
library(lubridate)

#session <- selenider_session("selenium",browser="chrome")
#open_url("https://appsgp.mypalmbeachclerk.com/eCaseView")
#
#rv <- session |> get_page_source() |> html_table() 
#print(rv[[1]])


startDate = ymd("2020-01-01")
endDate = ymd("2020-01-03")

for (d in as.list(seq(startDate,endDate,as.difftime(days(1)))))
{
  print(d)
}