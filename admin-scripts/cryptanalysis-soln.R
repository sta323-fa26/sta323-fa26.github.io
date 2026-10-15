
# load the data
trans.prob.mat = readRDS("data/trans-prob-mat.rds")
cipher_text = readLines("https://sta323-fa26.github.io/data/ciphertext.txt")

# trans.prob.mat |>
#   as.matrix() |>
#   saveRDS("data/trans-prob-mat.rds")

## Exercise 1

trans.prob.mat |>
  as.table() |>
  as.data.frame() |> 
  ggplot(aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 6
    ),
    axis.text.y = element_text(size = 6)) +
  coord_flip()
  

## Exercise 3
alphabet <- c(LETTERS, " ")
decode <- function(key, coded) {
  coded <- toupper(coded)
  decoded = coded
  for (i in 1:nchar(coded)) {
    substring(decoded, i, i) = alphabet[key == substring(coded, i, i)]
  }
  decoded
}

## Exercise 4

## alphabet with space
alphabet = c(LETTERS, " ")

## decode: replace ciphertext with key

decode = function(key, coded) {
  coded = toupper(coded)
  decoded = coded
  for (i in 1:nchar(coded)) {
    substring(decoded, i, i) = alphabet[key == substring(coded, i, i)]
  }
  decoded
}

score <- function(decoded) {
  logprob <- 0
  prevletter <- "SPACE"
  for (i in 1:nchar(decoded)) {
    curletter <- substring(decoded, i, i)
    if(curletter == " ") {
      curletter <- "SPACE"
    }
    logprob <- logprob + log(trans.prob.mat[rownames(trans.prob.mat) == prevletter,
                                            colnames(trans.prob.mat) == curletter])
    prevletter <- curletter
  }
  return(logprob)
} 

set.seed(360)
accept = 0
S = 5000
## one possible starting guess:
# key = sample(alphabet, size = 27, replace = FALSE)

## another starting key: 
key = alphabet

best_guess = decode(key, cipher_text)
score_max = score(best_guess)
SCORES <- NULL
for (s in 1:S) {
  ## change 2 characters
  proposal = sample(1:26, 2) # select 2 letters to switch
  prop.key = key
  prop.key[proposal[1]] = key[proposal[2]]
  prop.key[proposal[2]] = key[proposal[1]]
  
  ## check plausibility
  
  score_proposed = score(decode(prop.key, cipher_text))
  score_current = score(decode(key, cipher_text))
  log.r = score_proposed - score_current
  
  ## accept/reject
  if (log(runif(1)) < log.r)  {
    key = prop.key
    accept = accept + 1
  }
  
  if (score_proposed > score_max) {
    score_max = score_proposed
    best_guess = decode(prop.key, cipher_text)
  }
  
  SCORES <- c(SCORES, score_current)
  
  if(s %% 100 == 0){
    cat("iteration ", s, ": ", decode(key, cipher_text), "\n")
  }
}


## PLOT 
data.frame(score = SCORES, iteration = 1:length(SCORES)) |>
  ggplot(aes(x = iteration, y = score)) +
  geom_line()

