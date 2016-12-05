# Introduction to JAGS – Presence/Absence Data

Lizards on islands
Polis et al. (1998) analyzed the probability of occupancy of islands by lizards as a function of the ratio of the islands’ perimeter to area ratio. The data from this investigation are available in islands.csv. The response data are binary (0 if there were no lizards found on the island; 1 if at least one lizard was observed). You are assuming that if you fail to find a lizard, none are present on the island.

(1)	Construct a simple Bayesian model that represents the probability of occupancy as:

logit(p<sub>i</sub>) = a + b*X<sub>i</sub>

where X<sub>i</sub> is the perimeter to area ratio of the i<sup>th</sup> sland. 

So, you have the deterministic model, the challenge is to choose the proper likelihood to link the data to the model. What likelihood function is needed to represent the data?  Estimate the posterior distribution of parameters a and b, assuming vague priors (think about what these should be).

(2)	Run MCMC using JAGS for three chains. Selecting initial conditions can be a bit tricky with the type of likelihood you will use here. You may get the error message:

```{r}
Error in jags.model("IslandBug II.R",
data = data, inits, n.chains = length(inits), : Error in node y[4] Observed node 
inconsistent with unobserved parents at initialization
```

To be on the safe side, choose initial values for a and b so that inverse.logit(a+b) is between .01 and .99. For some reason that I don’t understand, JAGS gets upset when this value is 0 or 1. Note that inverse logit is ilogit() in JAGS and plogis() in R.

(3)	Plot the posterior density and the trace of the chains using

```{r}
plot(model_out_name)
traceplot(model_out_name)
```

Does the traceplot indicate convergence? Why? Are all Gelman-Rubin values (Rhats) near 1? 

(4)	Plot the raw data as points. 

(5)	Overlay the data plot with a line plot of the median and 95% credible intervals of the predicted probability of occurrence as a function of island perimeter to area ratios ranging from 1-60. 

_Hint: create a vector of 1-60 in R, and use it as x values for an equation making predictions in your JAGS code (as a derived parameter)._

(6)	Assume you are interested in 2 islands, 1 that has a perimeter to area ratio of 10, the other that has a perimeter to area ratio of 20. 

_What is the 95% credible interval on the difference in the probability of occupancy of the two islands based on the analysis you did above?_
_Hint – add this as a derived parameter._

(7)	_What fundamentally important source of error are we sweeping under the rug in all of these fancy calculations?_
_What are the consequences of failing to consider this error for our estimates?_
_Do you have some ideas about how we might cope with this problem?_




