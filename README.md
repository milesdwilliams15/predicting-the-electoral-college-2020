# Predicting the Electoral College in 2020
I've used the FiveThirtyEight aggregated polls to predict who wins the electoral college in 2020 (updated as of Oct. 28, 2020).

See a heat map of electoral college predictions here: [electoral heat map](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/electoral_map.pdf)

You can find Biden's predicted margin in the Electoral College here: [Bidens Margin of Victory](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.pdf)

## Methodological Notes

To generate these predictions, I used state polls with end-dates from Oct. 1 to Nov. 3. Because win probabilities for several states were either 1 or 0 (which seemed like *way* too much certainty), I hedged predictions by setting win probabilities to be no greater than 99% and no less than 1% for a given state. This choice added more uncertainty to the predictions and ultimately made the results *slightly less* bullish for Biden. That said, the simulation results indicate that Biden's chances of winning are approximately 98 out of 100. FiveThirtyEight readers will no doubt recognize that Nate Silver's predictions are far more conservative (89 out of 100 as of Oct. 20, 2020). I don't think my predictions are better, and a Biden victory in November certainly should not be taken as evidence that his chances were 98 out of 100 rather than 89.

## Post Mortem

The results of the 2020 presidential election (as of this writing) seem clear. Joe Biden has won the presidency with 306 electoral votes---a comfortable margin of victory indeed. However, while my simulation showed Biden's chances of winning at 49 out of 50, the most probable outcome was an electoral victory on the order of 349 electoral college votes. In fact, while Biden's chances of winning in my simulation were quite good, the likelihood that he would win with *only* 306 electoral votes was rather small.

There has been a lot of talk lately about how the polls (as in 2016) missed their mark, giving Biden (and the Democratic Party more generally) more favorable margins than he (and they), in actuality had. This got me to thinking: how might my predictions have differed if I had relied on the [prediction market](https://www.predictit.org/)? Better yet, what if I had taken a Bayesian approach, using prediction market prices as prior beleifs about Biden's chances of winning in a given state, and updating those beliefs with the polls?<sup>[1](#myfootnote1)</sup>

Here's how my predictions on the eve of the election would have differed:

First, as shown in the below figure, while Biden's median electoral total after 999 simulated elections was 349 when using polling data, the median outcome was a more modest 300 when basing predictions on betting market prices.<sup>[2](#myfootnote2)</sup> Meanwhile, when using the polls to update the betting market's beliefs (as reflected in prices) Biden's median electoral total after 999 electios was 323.

![Election Outcomes](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/expected-margin.png)

Now, these results should not, in any way, lead us to conclude that the betting market was more right than the polls. After all, while an electoral victory with 306 votes was a more likely possibility under the betting markets than the polls, it was also *not impossible* according to the polls. The above figure includes 95% quantile intervals which show the range of outcomes from the 2.5 to 97.5 percentiles produced in election simulations. A Biden victory with 306 electoral votes was within that margin according to simulations based on the polls. 

Nevertheless, informed as we are with this data, it is impossible to know whether the market was correct, and Biden winning 306 votes was always the most likely thing to happen, or if the polls were correct and we witnessed by some fluke the occurence of a lower probability event. To really know which was closer to the truth, we would have to repeat the actual election multiple times and document how Biden performed in each. But, alas, we cannot reset and repeat the real world presidential election (as much as a certain incumbent might like to do just that).

However, we can entertain another question: how surprised would we have been that Biden won in 2020 with 306 electoral votes if we had relied on the betting markets, the polls, or some combination? This question not only is answerable, we can put an exact number on it. Consider the following distribution of election outcomes from the election simulations.

![distribution](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/distribution.png)

This figure shows the proportion out of 999 simulated elections that Biden received a certain number of electoral college votes. The bottom, middle, and top panels are based on state-level probabilities as determined by betting market prices, polls, and Bayesian updating respectively. Clearly, we can see that under each of these approaches, the method that would leave us least surprised to see Biden win with 306 votes was the prediction market, followed by the Bayesian approach and the polls, in that order.

To put a precise number on it, let's assume that we wanted to know how surprising it would be for Biden win the election with at most 306 electoral votes---that is, for him to win between 270 and 306 votes. The below figure shows the percentage of elections where Biden won the election by securing so many electoral votes. As we should expect, the betting market would have left us least surprised by the ultimate electoral outcome. Biden had a nearly 4 in 10 chance of winning the election with at most 306 votes according to simulations based on market prices. Even with the Bayesian approach, leveraging information from both the market and the polls, we would have been little surprised to see Biden win by at most 306 votes. In simulations based on posterior predictions, Biden had a 1 in 4 chance of winning the election. For reference, those odds are the same as those of flipping a coin and getting "heads" twice in a row---so pretty good odds. However, if we relied purely on the polls to generate predictions (as I did on the eve of the election), Biden winning by at most 306 votes would have been most surprising indeed (as in fact it was). Here, Biden's chance of winning with at most 306 electoral votes was only 1 in 20.

![surprise](https://github.com/milesdwilliams15/predicting-the-electoral-college-2020/blob/main/03_figures/surprise.png)

Again, while this is not proof that the polls were wrong, this analysis does suggest that if the polls were right, we witnessed a rare event on Nov. 3rd.

<a name="myfootnote1">1</a>: For a given state, the prior probability of a Biden win is denoted as &alpha;<sub>0</sub> = price (in cents). The likelihood, based on the polling data, is &alpha; = proportion of polls per state where Biden wins. The posterior prediction is given as &alpha;'/(&alpha;' + &beta;') where &alpha;' = &alpha;<sub>0</sub> + &alpha; and &beta;' = (1 - &alpha;<sub>0</sub>) + (1 - &alpha;).

<a name="myfootnote2">2</a>: I used prices as of [Oct. 30](https://analysis.predictit.org/).
