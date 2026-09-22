library(ghclass)

####################################
## Individual assignment creation ##
####################################. 
this_org <- "sta323-fa26"
assignment <- "lab-3"


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

roster = readxl::read_xlsx("~/Downloads/teams_public_sta323_fa26.xlsx")

this_org <- "sta323-fa26"
assignment <- "lab-4"

org_create_assignment(
  org = this_org,
  user = roster$github,
  repo = paste0(assignment, "-", roster$team_name),
  team = roster$team,
  source_repo = paste0(this_org, "/", assignment),
  private = TRUE
)
# REPO DELETION
# roster <- readxl::read_xlsx("~/Downloads/teams_public_sta323_fa26.xlsx")
# repos <- unique(paste0("sta323-fa26/lab-4-", roster$team_name))
# repo_delete(repos)