library(ghclass)

####################################
## Individual assignment creation ##
####################################. 
this_org <- "sta323-fa26"
assignment <- "lab-2"


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


####################################
## Team based assignment creation ##
####################################. 
#
## ATTENTION
### MAKE SURE YOU PUT ALL ROSTER IN 1 EXCEL SHEET
##################################################

roster = readxl::read_xlsx("~/Downloads/teams_final.xlsx")

# edit "lab-x" below

org_create_assignment(
  org = "sta323-fa25",
  user = roster$github,
  repo = paste0("lab-7-", roster$team),
  team = roster$team,
  source_repo = "sta323-fa25/lab07",
  private = TRUE
)