# Predicting the Electoral College in 2020
I've used the 538 aggregated polls to predict who wins the electoral college in 2020 (updated as of Oct. 28, 2020).

See a heat map of electoral college predictions here: [electoral heat map](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/electoral_map.pdf)

You can find Biden's predicted margin in the Electoral College here: [Bidens Margin of Victory](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.pdf)

## Methodological Notes

To generate these predictions, I used state polls with end-dates from Oct. 1 to Nov. 3. Because win probabilities for several states were either 1 or 0 (which seemed like *way* too much certainty), I hedged predictions by setting win probabilities to be no greater than 99% and no less than 1% for a given state. This choice added more uncertainty to the predictions and ultimately made the results *slightly less* bullish for Biden. That said, the simulation results indicate that Biden's chances of winning are approximately 98 out of 100. FiveThirtyEight readers will no doubt recognize that Nate Silver's predictions are far more conservative (89 out of 100 as of Oct. 20, 2020). I don't think my predictions are better, and a Biden victory in November certainly should not be taken as evidence that his chances were 98 out of 100 rather than 89.

## Post Mortem

The results of the 2020 presidential election (as of this writing) seem clear. Joe Biden has won the presidency with 306 electoral votes---a comfortable margin of victory indeed. However, while my simulation showed Biden's chances of winning at 49 out of 50, the most probable outcome was an electoral victory on the order of 349 electoral college votes. In fact, while Bidens chances of winning in my simulation were quite good, the likelihood that he would win with *only* 306 electoral votes was rather small.

There has been a lot of talk lately about how the polls (as in 2016) missed their mark, giving Biden (and the Democratic Party more generally) more favorable margins than he (and they), in actuality had. This got me to thinking: how might my predictions have differed if I had relied on the [prediction market](https://www.predictit.org/)? Better yet, what if I had taken a Bayesian approach, using prediction market prices as prior beleifs about Biden's chances of winning in a given state, and updating those beliefs with the polls?

Here's how my predictions on the eve of the election would have differed:

First, as shown in the below figure, while Biden's median electoral total after 999 simulated elections was 349, the median outcomes was a more modest 300 when basing predictions on betting market prices. As we would also expect, Biden's median electoral total of 323 using a Bayesian approach lies between what the prediction market or the polls alone would suggest.

![Election Outcomes](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.png)

Now, these results should not, in any way, lead us to conclude that the betting markets were more right than the polls. After all, while an electoral victory with 306 votes was a more likely possibility under the betting markets than the polls, it was also *not impossible* according to the polls. Unlike in a computer simulation, we cannot reset and repeat the real world presidential election (as much as a certain incumbent might like to do just that). It therefore is impossible to know whether the markets were correct, and Biden winning 306 votes was always the most likely thing to happen, or if the polls were correct and we witnessed by some fluke the occurence of a lower probability event.

However, we can entertain another question: how surprised would we have been that Biden won in 2020 with 306 electoral votes if we had relied on the betting markets, the polls, or some combination? This question not only is answerable, we can put an exact number on it. Consider the following distribution of election outcomes per three different Monte Carlo experiments.

![distribution](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.png)

This figure shows the proportion out of 999 simulated elections that Biden received a certain number of electoral college votes. The bottom, middle, and top panels are based on state-level probabilities as determined by betting market prices, polls, and Bayesian updating respectively. Clearly, we can see that under each of these approaches, the method that would leave us least surprised to see Biden win with 306 votes was the prediction market, followed by the Bayesian approach and the polls, in that order.

To put a precise number on it, let's assume that we wanted to know how surprising it would be for Biden win the election with as little as 306 electoral votes---that is, for him to win 270 to 306 votes. As the below figure shows, such an outcome is hardly surprising at all if predictions were based on the betting market: Biden wins with at most 306 votes almost in 4 of10 elections. Even with the Bayesian approach, we would be little surprised to see Biden win by at most 306 votes. This occured in every 1 out of 4 elections. However, if we relied purely on the polls to generate predictions (as I did), Biden winning by at most 306 votes would have been surprising indeed (as in fact it was). Here, Biden's chance of winning with such a margin was only 1 in 20.

![surprise](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/surprise.png)

Again, while this is not proof that the polls were wrong, this post mortem does suggest that if the polls were right, we witnessed a rare event on Nov. 3rd.
