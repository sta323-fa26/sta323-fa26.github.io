library(tidyverse)
library(ghclass)

## read intake form
df <- read_csv("/Users/athos/Desktop/teaching/sta323_fa26/intake/fa26_gh_roster1.csv") |>
  drop_na()

gh_usernames <- df[,2]
# gh_usernames <- "fishswish" # test

ghclass::org_invite(org = "sta323-fa26", user = gh_usernames)
