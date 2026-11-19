library(tidyverse)
library(httr2)

### Download individual pages ###


## First page (request max pg size results)
houses =
  jsonlite::read_json("https://www.anapioficeandfire.com/api/houses?pageSize=50") |>
  tibble(house = _) |>
  unnest_wider(house)

houses

## Second page (notice page=2)
houses2 =
  jsonlite::read_json("https://www.anapioficeandfire.com/api/houses?pageSize=50&page=2") |>
  tibble(house = _) |>
  unnest_wider(house)


### Pagination ###
# how many pages are there?

page = 1
HOUSES = list()

repeat {
  cat("\nDownloading page ", page)
  
  house = jsonlite::read_json(
    glue::glue(
      "https://www.anapioficeandfire.com/api/houses?pageSize=50&page={page}"
    )
  )
  
  # save the current page, including a potentially incomplete final page
  HOUSES = c(HOUSES, house)
  
  # stop when fewer than 50 houses are returned
  if (length(house) < 50) {
    break
  }
  
  page = page + 1
}

length(HOUSES)


### More robust pagination: HTTP Link headers ###

# Request the first page
resp = request("https://www.anapioficeandfire.com/api/houses") |>
  req_url_query(pageSize = 50, page = 1) |>
  req_perform()

# Examine response metadata
resp |>
  resp_headers("link")

resp |>
  resp_status()


### helper function: extract pagination links ###

get_links = function(resp) {
  link = resp |> resp_header("link")
  
  if (is.null(link))
    return(list())
  
  matches = link |>
    str_match_all('<(.*?)>; rel="(.*?)"') |>
    (\(x) x[[1]])()
  
  setNames(as.list(matches[, 2]), matches[, 3])
}

# inspect the links returned by the API
get_links(resp)


### plan: follow the "next" link until no pages remain ###

result = list()
page = 1

repeat {
  cat("\nGetting page ", page)
  
  # store the current page, including the first and last pages
  result = c(result, resp |>
               resp_body_json())
  
  # find the URL of the next page
  links = get_links(resp)
  nextLink = links[["next"]]
  
  # no next link means we've reached the last page
  if (is.null(nextLink)) {
    break
  }
  
  cat("\nNext link: ", nextLink)
  
  # request the next page
  resp = request(nextLink) |>
    req_perform()
  
  page = page + 1
}

length(result)


##################
### EXERCISE 1 ###
##################


res = list()
page = 1
pageSize = 50

repeat {
  
  cat("Reading page ", page, "\n")
  
  d = jsonlite::read_json(glue::glue(
    "https://www.anapioficeandfire.com/api/characters?pageSize=50&page={page}"
  ))
  
  res = c(res, d)
  
  if(length(d) != pageSize) {
    break
  }
  
  
  page = page + 1
}

length(res)
# there are 2134 characters

################
## EXERCISE 2 ## 
################
char = res %>%
  tibble(char = .) %>%
  unnest_wider(char)

char %>%
  nrow()

char %>%
  summarize(prop_alive = sum(died == "") / nrow(char))

