library(selenider)
library(rvest)

session <- selenider_session("selenium",browser="chrome")
open_url("https://appsgp.mypalmbeachclerk.com/eCaseView")

rv <- session |> get_page_source() |> html_table() 
print(rv[[1]])