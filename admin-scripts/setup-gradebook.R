library(tidyverse)

box <- read_csv("~/Downloads/grades(Sheet1).csv") # pre-populated from canvas CSV
duke_hub_roster <- read_csv("~/Downloads/Class Roster - 2026 Fall Term - STA 323L (5398)(2).csv")
github_survey <- read_csv("~/Downloads/STA323_Fall2026_Responses - Form Responses 1.csv") |>
  drop_na() |>
  select(2, 3, 4)

###########################
## wrangle gitHub survey ##
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
duke_hub_roster <- duke_hub_roster |>
  select(1, 2, 4) |>
  mutate(`SIS User ID` = as.double(str_extract(`Student ID`, "(?<=DUID: )\\d+"))) |>
  select(2:4) |>
  rename(email = `Email Address`)

# explanation
## (?<=DUID: ) look behind and match something only if it is immediately preceded by the literal text "DUID: "
# () defines the group
#? special 
# < look to the left
# = match exact
#########################
## combine data frames ## 
#########################

x <- left_join(duke_hub_roster, github_survey) |>
  select("SIS User ID", "github")
## fix:
cat("FIX:\n") 
x[which(is.na(x$github)),]

box2 <- box |>
  select(-"github") |>
  left_join(x) |>
  relocate(names(box))

write_csv(box2, "~/Downloads/box2.csv")
