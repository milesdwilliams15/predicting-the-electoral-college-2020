# Predicting the Electoral College in 2020
I've used the 538 aggregated polls to predict who wins the electoral college in 2020 (updated as of Oct. 28, 2020).

See a heat map of electoral college predictions here: [electoral heat map](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/electoral_map.pdf)

You can find Biden's predicted margin in the Electoral College here: [Bidens Margin of Victory](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.pdf)

## Methodological Notes

To generate these predictions, I used state polls with end-dates from Oct. 1 to Nov. 3. Because win probabilities for several states were either 1 or 0 (which seemed like *way* too much certainty), I hedged predictions by setting win probabilities to be no greater than 95% and no less than 5% for a given state. This choice added more uncertainty to the predictions and ultimately made the results *slightly less* bullish for Biden. That said, the simulation results indicate that Biden's chances of winning are approximately 98 out of 100. FiveThirtyEight readers will no doubt recognize that Nate Silver's predictions are far more conservative (89 out of 100 as of Oct. 20, 2020). I don't think my predictions are better, and a Biden victory in November certainly should not be taken as evidence that his chances where 98 out of 100 rather than 89.

