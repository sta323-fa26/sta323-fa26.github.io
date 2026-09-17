# edit paths:
library(tidyverse)
grades <- readxl::read_xlsx("~/Downloads/grades(3).xlsx")
## Recall there are hidden columns in the data frame

grades |>
  select(Student, ID, `SIS User ID`, `SIS Login ID`, Section,
         quiz01) |> # edit assignments 
  # mutate(across(c(quiz03, quiz04, quiz05), ~replace_na(., 0))) |>
  write_csv(paste0("~/Downloads/upload323-", Sys.Date(), ".csv"))
