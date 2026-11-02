# edit paths:
library(tidyverse)
grades <- readxl::read_xlsx("~/Downloads/grades(4).xlsx")
grades <- read_csv("~/Downloads/boxgrades-001.csv")
## Recall there are hidden columns in the data frame

grades |>
  select(Student, ID, `SIS User ID`, `SIS Login ID`, Section,
         quiz04, quiz05) |> # edit assignments 
  # mutate(across(c(quiz03, quiz04, quiz05), ~replace_na(., 0))) |>
  write_csv(paste0("~/Downloads/upload323-", Sys.Date(), ".csv"))
