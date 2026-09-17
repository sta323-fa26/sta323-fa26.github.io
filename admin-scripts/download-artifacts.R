library(ghclass)

##################################
### to download the html files ###
##################################
repos_of_interest = ghclass::org_repos("sta323-fa26", filter="lab-2")
ghclass::action_artifact_download(repos_of_interest,
                                  dir = paste0("~/Downloads/sta323-", Sys.Date()),
                                  overwrite = FALSE)


###########################
### clean up artifacts ###
##########################
repos_of_interest = ghclass::org_repos("sta323-fa26", filter="lab-1")
ghclass::action_artifact_delete(repos_of_interest, ids=action_artifacts(repos_of_interest, which="all"))

