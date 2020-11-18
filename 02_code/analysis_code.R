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

# State abbreviations:
abbs <- tibble(state_ID = c(state.abb,"DC"),
               state = c(state.name,"District of Columbia"))

# Polls from 538
polls <- read_csv(
  "01_data/polls.csv"
)

# Marke prices from PredictIt
markets <- read_csv(
  "01_data/markets.csv"
) %>% left_join(
  abbs, by = 'state_ID'
)

# Electoral college totals per state
ec <- read_csv(
  "01_data/tables2012.csv"
) %>%
  mutate(
    dem = replace_na(dem,0),
    rep = replace_na(rep,0),
    total = dem + rep
  ) %>%
  select(-dem,-rep) %>%
  left_join(
    abbs, by = 'state_ID'
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

state_outcomes <- state_outcomes %>%
  filter(state %in% state.name) %>%
  filter(candidate == 'Biden_prop') %>%
  arrange(state) %>%
  left_join(markets,by='state') %>%
  left_join(ec,by='state') %>%
  select(state,everything(),-candidate,-
           contains('ID'))

# calculate bayesian probabilities using
# market prices as priors
bern_post <- function(prior,like) {
  success <- prior + like
  failure <- (1-prior) + (1-like)
  prediction <- success/(success + failure)
  return(prediction)
}
state_outcomes %>%
  mutate(
    win_prob = case_when(
      win_prob == 1 ~ 0.99,
      win_prob == 0 ~ 0.01,
      win_prob <1 & win_prob>0 ~ win_prob
    )
  ) %>%
  mutate(
    post_prob = bern_post(
      prior = market_price,
      like = win_prob
    )
  ) -> state_outcomes

# simulate 40,000 elections
elections <- 999 #40000
outcomes <- list() # 1 will equal Biden victory
for(i in 1:elections) {
  cat('Election',i,'of',elections,'\r\r\r\r\r')
  
  # reveal outcomes
  outcomes[[i]] <- state_outcomes %>%
      mutate(
        polls = rbinom(n(),1,win_prob),
        prices = rbinom(n(),1,market_price),
        bayes = rbinom(n(),1,post_prob)
    ) %>%
    summarize(
      polls = sum(total*polls),
      prices = sum(total*prices),
      bayes = sum(total*bayes)
    ) 
  
  if(i == elections) cat('\nDone!')
}
do.call(rbind,outcomes) %>%
  mutate(
    polls_win = polls >=270,
    prices_win = prices >= 270,
    bayes_win = bayes >= 270
  ) -> outcomes

outcomes %>%
  summarize_at(
    c('polls','prices','bayes'),
    .funs = c(median,
              function(x) quantile(x,.025),
              function(x) quantile(x,0.975))
  ) -> smry
smry %>%
  gather() %>%
  mutate(
    key = c(
      rep('Median',len=3),
      rep('2.5 Percentile',len=3),
      rep('97.5 Percentile',len=3)
    ),
    Method = c(
      rep(
        c('Polls','Prices','Bayes'),
        len=9
      )
    )
  ) %>%
  spread(
    key = key,
    value = value
  ) -> smry

ggplot(smry) +
  aes(
    Median,
    reorder(Method,-Median),
    xmin = `2.5 Percentile`,
    xmax = `97.5 Percentile`,
    label = Median
  ) +
  geom_col(
    fill = 'darkorange'
  ) +
  geom_errorbarh(
    height = .1
  ) +
  geom_text(
    vjust = 1,
    hjust = 0
  ) +
  geom_vline(
    xintercept = 270,
    lty = 2
  ) +
  labs(
    x = 'Electoral Votes for Biden',
    y = ' ',
    title = 'Simulated Electoral Outcomes',
    subtitle = 'U.S. President 2020',
    caption = 'milesdwilliams15'
  ) +
  scale_x_continuous(
    breaks = c(
      c(0,100,200,270,300,400)
    ) 
  ) +
  ggridges::theme_ridges() +
  theme(
    axis.text.x = element_text(
      angle = 45, hjust = 1,
      face = c('italic',
               'italic',
               'italic',
               'bold.italic',
               'italic',
               'italic')
    )
  ) + 
  ggsave(
    '03_figures/expected-margin.png',
    height = 4,
    width = 6
  )

# probability of 306 electoral votes


bind_rows(
  outcomes %>% count(polls) %>% 
    rename(votes = polls) %>%
    mutate(Method = 'Polls'),
  outcomes %>% count(prices) %>%
    rename(votes = prices) %>%
    mutate(Method = 'Prices'),
  outcomes %>% count(bayes) %>%
    rename(votes = bayes) %>%
    mutate(Method = 'Bayes')
) %>% 
  mutate(
    percent = n/elections*100
  ) -> counts

counts %>%
  filter(votes <= 306 & votes >= 270) %>%
  group_by(Method) %>%
  summarize(
    percent = sum(percent)
  ) %>%
  ggplot() +
  aes(
    percent, reorder(Method,percent),
    label = round(percent,1)
  ) +
  geom_point() +
  geom_text(vjust = -1) +
  xlim(c(0,40)) +
  labs(
    x = 'Percent Wins with 306 Votes',
    y = '',
    title = 'Simulated Electoral Outcomes',
    subtitle = 'U.S. President 2020',
    caption = 'milesdwilliams15'
  ) +
  ggridges::theme_ridges() +
  theme(
    panel.grid.major.y = element_line(
      linetype = 3, color = 'black'
    )
  ) +
  ggsave(
    '03_figures/surprise.png',
    height = 4,
    width = 6
  )

counts %>%
  ggplot() +
  aes(
    votes, percent/100,
    fill = Method
  ) +
  geom_col(alpha = .5) +
  labs(
    x = 'Electoral Votes for Biden',
    y = 'Probability',
    title = "Simulated Electoral Outcomes",
    subtitle = "U.S. President 2020",
    caption = 'milesdwilliams15'
  ) +
  geom_vline(
    xintercept = 270,lty=2
  ) +
  scale_x_continuous(
    breaks = c(
      c(200,270,300,400)
    )
  ) +
  facet_wrap(~ Method, ncol = 1) +
  ggridges::theme_ridges() +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(
      angle = 45, hjust = 1,
      face = c('italic',
               'bold.italic',
               'italic',
               'italic')
    )
  ) +
  ggsave(
    '03_figures/distribution.png',
    height = 4,
    width = 6
  )
