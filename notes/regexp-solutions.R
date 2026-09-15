library(tidyverse)
## Exercise 1

emails <- readLines("https://sta323-fa26.github.io/data/emails.txt")

str_match(emails, 
                "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+") |>
  data.frame(email = _) |>
  drop_na() |> 
  mutate(domain = str_extract(email, ("(?<=@)[^.*]+")))

# alternate solution to ex 1

str_match(emails, 
          "(?:[A-Za-z0-9._%+-]+)@([A-Za-z0-9]+)\\..*") |>
  data.frame(email = _) |>
  drop_na()
#####
## notice, ?: prevents certain groups from being separately captured by str_match.
#####

## Exercise 2

files <- list.files("secret-messages/", pattern = ".txt")
for (file in files) {
  x <- readLines(paste0("secret-messages/", file))
  str_extract(x, "sta323\\{.*\\}") |>
    print()
}
