library(tidyverse)

box <- read_csv("~/Downloads/grades(Sheet1).csv") # pre-populated from canvas CSV
duke_hub_roster <- read_csv("~/Downloads/Class Roster - 2026 Fall Term - STA 323L (5398)(2).csv")
github_survey <- read_csv("~/Downloads/STA323_Fall2026_Responses - Form Responses 1.csv") |>
  drop_na() |>
  select(2, 3, 4)

###########################
## wrangle GitHub survey ##
###########################

names(github_survey) = c("github", "netid", "email")

# if the survey question "email" contains a number,
# then it may not be a 'name email'
# but instead a netID email
github_survey <- github_survey |>
  mutate(nameEmail = !str_detect(github_survey$email, "\\d"))

warn_email <- function(df) {
  if (sum(df$nameEmail != 0)) {
    warning("The following students possibly have a mismatched email", immediate. = TRUE)
  }
  df |>
    filter(nameEmail == FALSE) |>
    print()
}

warn_email(github_survey)

#############################
## wrangle duke hub roster ## 
#############################

# SIS User ID on Canvas is the same as Duke ID on DukeHub # 

## get SIS ids:
sis <- str_extract(duke_hub_roster$`Student ID`, "DUID: \\d*") |>
  str_split(" ", simplify = TRUE) |>
  (\(x) x[,2])()
  
duke_hub_roster |>
  select(1, 2, 4) |>
  mutate(`SIS User ID` = sis) 
