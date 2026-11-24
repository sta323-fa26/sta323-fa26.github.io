# edit paths:
library(tidyverse)
grades <- readxl::read_xlsx("~/Downloads/grades(6).xlsx")
# grades <- read_csv("~/Downloads/boxgrades-001.csv")
## Recall there are hidden columns in the data frame

grades |>
  select(Student, ID, `SIS User ID`, `SIS Login ID`, Section,
         quiz06, `quiz07-optional`) |> # edit assignments 
  # mutate(across(c(quiz03, quiz04, quiz05), ~replace_na(., 0))) |>
  write_csv(paste0("~/Downloads/upload323-", Sys.Date(), ".csv"))

## optional: 
x <- read_csv("~/Downloads/exam2_scores.csv") |>
  mutate(exam2 = `Total Score`) |>
  select(SID, exam2) 

grades |>
  left_join(x, by = c(`SIS User ID` = "SID")) |>
  select(Student, ID, `SIS User ID`, `SIS Login ID`, Section,
         quiz06, `quiz07-optional`, exam2) |> # edit assignments 
  # mutate(across(c(quiz03, quiz04, quiz05), ~replace_na(., 0))) |>
  write_csv(paste0("~/Downloads/upload323-", Sys.Date(), ".csv"))
