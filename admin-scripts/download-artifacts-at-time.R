target <- as.POSIXct("2026-09-10 10:45:00")

seconds_until_target <- as.numeric(
  difftime(target, Sys.time(), units = "secs")
)

if (seconds_until_target <= 0) {
  stop("The scheduled time has already passed.")
}

message("Waiting until ", target)
Sys.sleep(seconds_until_target)

x <- rnorm(100)
y <- rnorm(100)
modelFit <- lm(y ~ x)
summary(modelFit)