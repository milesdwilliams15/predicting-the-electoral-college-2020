#######################################
# Analysis Script for Predicting 2020 #
# Electoral College Map               #
#######################################

# Data for this analysis come from 538's
# election-forcast-2020 .zip folder.
# file name: presidential_polls_2020.csv


# libraries ---------------------------------------------------------------

library(tidyverse)

# data --------------------------------------------------------------------

polls <- read_csv(
  "01_data/polls.csv"
)

# size of the data:
dim(polls)

# put dates in date format
polls %>%
  mutate(
    modeldate = as.Date(
      modeldate, "%m/%d/%y"
    ),
    startdate = as.Date(
      startdate, "%m/%d/%y"
    ),
    enddate = as.Date(
      enddate, "%m/%d/%y"
    )
  ) -> polls

# hone in on polls with enddates 
# from Oct. 1 to Nov. 3
polls %>%
  filter(
    enddate <= "2020-11-4" &
      enddate >= "2020-10-1"
  ) -> polls


# look at poll spread over time -------------------------------------------

ggplot(polls) +
  aes(
    enddate, pct,
    color = candidate_name
  ) +
  geom_point(alpha = .05) +
  geom_smooth() +
  scale_color_manual(
    values = c('red','blue')
  ) +
  labs(
    x = "",
    y = 'Percentage',
    color = ''
  ) +
  theme(
    legend.position = 'top'
  ) +
  ggsave(
    '03_figures/polls-over-time.pdf',
    height = 5,
    width = 7
  )


# estimate candidate percentages by state ---------------------------------

# Clean up
polls %>%
  select(
    state, enddate, candidate_name, pct, weight
  ) %>%
  spread(
    candidate_name, pct
  ) %>%
  rename(
    Trump = `Donald Trump`,
    Biden = `Joseph R. Biden Jr.`
  ) %>%
  mutate(
    Biden_margin = Biden - Trump,
    Biden_win = as.numeric(Biden_margin>0)
  ) -> tidy_polls

# Estimate weighted proportion of polls
# where Biden wins by state:
tidy_polls %>%
  group_by(state) %>%
  summarize(
    Biden_prop = sum(weight*Biden_win)/sum(weight),
    Trump_prop = 1 - Biden_prop
  ) %>%
  arrange(-Biden_prop) %>%
  gather(
    key = 'candidate',
    value = 'win_prob',
    -state
  ) -> state_outcomes


# plot Trum/Biden probabilities by state ----------------------------------

# Bar Plot:
state_outcomes %>%
  mutate(
    order_var = c(
      win_prob[candidate=='Biden_prop'],
      win_prob[candidate=='Biden_prop']
    )
  ) %>%
  ggplot() +
  aes(
    win_prob,
    reorder(
      state,
      order_var
    ),
    fill = candidate
  ) +
  geom_col() +
  scale_fill_manual(
    values = c('blue','red'),
    labels = c('Biden','Trump')
  ) +
  labs(
    x = 'Win Probability',
    y = '',
    fill = ''
  ) +
  theme(
    legend.position = 'top'
  ) +
  ggsave(
    '03_figures/win_probs.pdf',
    height = 8,
    width = 5
  )

# Heat Map
library(usmap)
plot_usmap(
  data = state_outcomes %>% filter(candidate=='Biden_prop'),
  values = 'win_prob',
  labels = F
) +
  scale_fill_gradient(
    low = 'red', high = 'blue'
  ) +
  labs(
    fill = 'Biden Win Probability'
  ) +
  theme(
    legend.position = 'top'
  ) +
  ggsave(
    '03_figures/electoral_map.pdf',
    height = 6, width = 6
  )
