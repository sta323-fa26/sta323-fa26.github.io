library(tidyverse)
library(ghclass)

#
## INITIAL
##### ORG 
######## INVITE


df <- read_csv("/Users/athos/Desktop/teaching/sta323_fa26/intake/fa26_gh_roster1.csv") |>
  drop_na()

gh_usernames <- df$`What is your GitHub username? e.g. reply "athos00" (no quotes)`
# gh_usernames <- "fishswish" # test

ghclass::org_invite(org = "sta323-fa26", user = gh_usernames)

#
## MAKE 
##### LAB 
######## ZERO 

this_org <- "sta323-fa26"
assignment <- "lab-0"

usernames <- ghclass::org_members(org = this_org)
repos <- paste0(assignment, "-", usernames)
existing_repos <- ghclass::org_repos(this_org, filter = assignment, full_repo = FALSE)

indices <- !(repos %in% existing_repos)
make_usernames <- usernames[indices]
make_repos <- repos[indices]

org_create_assignment(
  org = this_org,
  user = make_usernames,
  repo = make_repos,
  source_repo = paste0(this_org,"/", assignment),
  private = TRUE
)

#ghclass::repo_add_user(repo = paste0("sta323-fa26/", repos), user = usernames, permission = "push")

#
## MAKE 
##### FUTURE 
######## LABS 

this_org <- "sta323-fa26"
assignment <- "lab-1"


usernames <- ghclass::org_members(org = this_org)
repos <- paste0(assignment, "-", usernames)
existing_repos <- ghclass::org_repos(this_org, filter = assignment, full_repo = FALSE)

indices <- !(repos %in% existing_repos)
make_usernames <- usernames[indices]
make_repos <- repos[indices]

org_create_assignment(
  org = this_org,
  user = make_usernames,
  repo = make_repos,
  source_repo = paste0(this_org,"/", assignment),
  private = TRUE
)
