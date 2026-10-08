## Ex 1

#We want the weather to be more persistent:
#   
#   - Dry $\rightarrow$ Dry with probability $0.95$
#   - Wet $\rightarrow$ Wet with probability $0.90$
#   
#   So the transition matrix is
# 
# $$
#   P =
#     \begin{pmatrix}
#   0.95 & 0.05 \\
#   0.10 & 0.90
#   \end{pmatrix}.
#   $$
#     
  P_persistent <- matrix(
    c(.95, .05,
      .10, .90),
    nrow = 2,
    byrow = TRUE,
    dimnames = list(
      from = states,
      to = states
    )
  )
  
  P_persistent
persistent_path <- simulate_chain(
  P_persistent,
  initial = "Dry",
  n_steps = 80
)

tibble(
  day = 0:80,
  state = factor(persistent_path, levels = states)
) |>
  ggplot(aes(x = day, y = state, group = 1)) +
  geom_line() +
  geom_point() +
  labs(
    x = "Day",
    y = NULL
  )
## Ex 2

#To make geographic spread much greater east/west than north/south, we can use

# $$
#   \Sigma =
#     \begin{pmatrix}
#   4 & 0 \\
#   0 & 0.25
#   \end{pmatrix}.
#   $$
#     
#The east/west variance is much larger than the north/south variance.
  
  Sigma_wide <- matrix(
    c(4, 0,
      0, .25),
    nrow = 2,
    byrow = TRUE
  )
  
  Sigma_wide
brownian_paths <- map_dfr(
  1:25,
  function(id) {
    simulate_brownian(
      n_steps = 100,
      sigma = Sigma_wide
    ) |>
      mutate(path = id)
  }
)

brownian_paths |>
  ggplot(
    aes(
      x = east_km,
      y = north_km,
      group = path
    )
  ) +
  geom_path(alpha = .4) +
  coord_equal() +
  labs(
    x = "Kilometers east/west",
    y = "Kilometers north/south"
  )