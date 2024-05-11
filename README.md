# `lrplot`
Plot effects after estimating an autoregressive distributed lag (ARDL) model.

# Description 
`lrplot` estimates and plots the period-specific and long-run effects of an autoregressive distributed lag (ARDL) model. 
`lrplot` simulates the effects by taking draws from a multivariate normal distribution where the means of each variable 
are the coefficients from the regression and the variance–covariance matrix is the variance–covariance matrix stored in e(V). 
`lrplot` works with any program as long as Stata's time series operators are used (see tsvarlist), and the program stores the
coefficients and variance-covariance matrix in e(b) and e(V). `lrplot` replaces the current dataset with the simulated data and the 
estimated effects by time period.

# Syntax

     lrplot varlist(max=1) [, time(integer 10) sims(integer 10000) seed(string) level(integer 95) line *]

# Options

Option | Description
--- | ---
**time(integer 10)** | number of times periods to simulate. Default is 10.
**sims(integer 10000)** | number of simulations. Default is 10000.
**seed(string)** | seed for random-number generator.
**level(integer 95)** | significance level for confidence intervals. Default 95%.
**line** | plot cumulative effect as a line graph instead of a bar graph.
**$\*$** | options for the plot (supports graph twoway options).

# Examples 

`lrplot` produces a table and a plot of the effects. It is important to note that the effects estimated by `lrplot` will differ
from those calculated with the `nlcom` command following estimation. This is because the effects estimated by `lrplot` are based 
on simulations. This also means that a seed must be set to reproduce results.

**1.  Estimate an ARDL(1,0) with `regress`**

        reg y l.y x

        lrplot x

**2.  Estimate an ARDL(1,1) with `xtreg, fe` over 50 time periods**

        xtreg l(0/1).(y x), fe

        lrplot x, time(50)

**3.  Estimate an ARDL with a more complex lag structure and a seed to reproduce results**

        xtreg y l2.y l3.y x l.x l5.x, fe

        lrplot x, seed(3424)

**4.  Plot the cumulative effect with a line graph instead of a bar graph with a custom x-axis title**

        xtreg y l1.y l2.y x i.time, fe

        lrplot x, time(75) seed(3424) line xtitle("Year")

**5.  `lrplot` also supports finite distributed lag models (only lags of x appear in the model)**

        reghdfe y l(0/4).x, a(id time)

        lrplot x, sims(1000)

# Install 

`lrplot` can be installed by typing the following in Stata:

    net install lrplot, from("https://raw.githubusercontent.com/rthombs/lrplot/main") replace

# Author

[**Ryan P. Thombs**](ryanthombs.com)  
**(Boston University)**  
**Contact Me: [rthombs@bu.edu](mailto:rthombs@bu.edu)**

