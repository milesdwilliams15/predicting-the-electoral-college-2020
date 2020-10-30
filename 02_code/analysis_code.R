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
    Biden_prop = sum(weight*Biden_win)/
      sum(weight),
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


# the likelihood of a Biden Victory ---------------------------------------

# load data on electoral college totals from 2012
ec <- read_csv(
  "01_data/tables2012.csv"
) %>%
  select(-X4,-X5) %>%
  mutate(
    dem = replace_na(dem,0),
    rep = replace_na(rep,0),
    total = dem + rep
  ) %>%
  select(-dem,-rep)

abbs <- tibble(state_ID = state.abb,state = state.name) 
state_outcomes <- state_outcomes %>%
  filter(state %in% state.name) %>%
  filter(candidate == 'Biden_prop') %>%
  arrange(state) %>%
  left_join(.,abbs,by='state') %>%
  left_join(.,ec,by='state_ID') %>%
  select(state_ID,state,everything(),-candidate)

# simulation 1000 elections
elections <- 1000
outcomes <- list() # 1 will equal Biden victory
for(i in 1:elections) {
  cat('Election',i,'of',elections,'\r\r\r\r\r')
  
  # reveal outcomes
  outcomes[[i]] <- state_outcomes %>%
    mutate(
      win_prob = case_when(
        win_prob == 1 ~ 0.95,
        win_prob == 0 ~ 0.05,
        win_prob <= 1 &
          win_prob >= 0 ~ win_prob
      )
    ) %>%
      mutate(
        outcome = rbinom(n(),1,win_prob)
    ) %>%
    summarize(
      total = sum(total*outcome)
    ) 
  
  if(i == elections) cat('\nDone!')
}
do.call(rbind,outcomes) %>%
  mutate(
    win = total>=270 %>% as.numeric
  ) -> outcomes

ggplot(outcomes) +
  aes(
    1:elections,
    total
  ) +
  geom_col(color = 'orange') +
  geom_hline(yintercept = 270,lty=2) +
  labs(
    x = 'Election',
    y = 'Electoral College Total'
  )

outcomes %>%
  summarize(
    median = median(total),
    lo = quantile(total,0.025),
    hi = quantile(total,0.975),
    wins = 100*mean(win)
  ) -> smry
ggplot(smry) +
  aes(
    x = median,
    y = 1,
    xmin = lo,
    xmax = hi
  ) +
  geom_point(col='darkorange') +
  geom_errorbarh(col='darkorange',height=.45) +
  geom_text(
    aes(label = paste0(median,' (Median)')),
    vjust = -1.5,
    hjust = 0.2,
    col = 'darkblue'
  ) +
  ggpubr::geom_bracket(
    y.position = 1.25,
    xmin = smry$lo,
    xmax = smry$hi,
    label = "95% of outcomes",
    col = 'darkgrey',
    vjust = 2
  ) +
  geom_vline(xintercept=270,lty=2) +
  scale_x_continuous(
    n.breaks = 20
  ) +
  scale_y_continuous(breaks=NULL) +
  labs(
    x='Electoral College Total',
    y='',
    title = "Biden's Expected Margin of Victory",
    subtitle = "Results from 1,000 elections"
  ) +
  annotate(
    'text',
    x = 320,
    y = .8,
    fontface = 'italic',
    label = paste0('Biden wins ',smry$wins,
                   '% of the time')
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(
      color = c(
        'black',
        rep('darkgrey',len=19)
      )
    ),
    plot.subtitle = element_text(
      face = 'italic'
    )
  ) +
  ggsave(
    '03_figures/expected-margin.pdf',
    height = 3,
    width = 4.5
  )


