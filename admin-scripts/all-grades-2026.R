library(tidyverse) 

################
## read files ##
################
box <- readxl::read_xlsx("~/Downloads/grades(5).xlsx") |>
  select(-c("exam1", "exam2"))
gradescope_exams <- 
  read_csv("~/Downloads/STA_323L.001.Fa26_Fall_2026_grades.csv")
template <- read_csv("~/Downloads/midterm_template.csv")

###################
## join together ##
###################
exam_subset <- gradescope_exams |>
  select(SID,exam1, Email)

df <- box |>
  left_join(exam_subset, by = c("SIS User ID" = "SID")) |>
  mutate(quizTotal = quiz01 + quiz02 + quiz03) |>
  mutate(quizPct = ifelse(quizTotal >= 7.2, 1, quizTotal / (3 * 4))) |>
  mutate(quizPct = 1) |>
  mutate(labPct = (lab01 + lab02 + lab03) / (3 * 12)) |> 
  mutate(examPct = exam1 / 50)

###########################
## compute midterm grade ##
###########################
mid_sem_grades <- df |>
  mutate(gradePct = ( (examPct * 25) + (quizPct * 5) + (labPct * 25) ) / 55) |>
  mutate(FINAL = 100 * gradePct) %>%
  mutate(letterGrade = case_when(FINAL >= 93 ~ "A",
                                 FINAL < 93 & FINAL >= 90 ~ "A-",
                                 FINAL < 90 & FINAL >= 87 ~ "B+",
                                 FINAL < 87 & FINAL >= 83 ~ "B",
                                 FINAL < 83 & FINAL >= 80 ~ "B-",
                                 FINAL < 80 & FINAL >= 77 ~ "C+",
                                 FINAL < 77 & FINAL >= 73 ~ "C",
                                 FINAL < 73 & FINAL >= 70 ~ "C-",
                                 FINAL < 70 & FINAL >= 67 ~ "D+",
                                 FINAL < 67 & FINAL >= 63 ~ "D",
                                 FINAL < 63 & FINAL >= 60 ~ "D-",
                                 FINAL < 60 ~ "F",
  ))


mid_sem_grades |>
  count(letterGrade)

# View(mid_sem_grades |>
#        select(Student, lab01, lab02, lab03, quiz01, quiz02, quiz03, exam1,
# labPct, quizPct, examPct, gradePct, FINAL, letterGrade))

###################
## create upload ##
###################

x <- mid_sem_grades |>
  select(Student, Email, letterGrade)

upload <- left_join(template, x, by = c("Email" = "Email"))

# upload |>
#   select(Name, Student, letterGrade) |>
#   View()

upload |>
  select(-Student) |>
  mutate("Official Grade" = letterGrade) |>
  select(-letterGrade) |>
  write_csv("~/Downloads/upload_mid_semester_323_fall2026.csv")
