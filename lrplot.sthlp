{smcl}
{* *! version 1.0  10may2024}{...}
{* *! Ryan Thombs, https://ryanthombs.com/}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "lrplot##syntax"}{...}
{viewerjumpto "Description" "lrplot##description"}{...}
{viewerjumpto "Examples" "lrplot##examples"}{...}
{viewerjumpto "Author" "lrplot##author"}{...}
{title:Title}

{phang}
{bf:lrplot {hline 2} Plot effects after estimating an autoregressive distributed lag (ARDL) model.}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:lrplot} {varlist}(max=1) [{cmd:,} {cmd:time(integer 10)} {cmd:sims(integer 10000)} {cmd:seed(string)} {cmd:level(integer 95)} {cmd:line} {cmd:*}]


{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt :{cmd:time(integer 10)}}number of times periods to simulate. Default is 10.{p_end}

{synopt :{cmd:sims(integer 10000)}}number of simulations. Default is 10000.{p_end}

{synopt :{cmd:seed(string)}}seed for random-number generator.{p_end}

{synopt :{cmd:level(integer 95)}}significance level for confidence intervals. Default 95%.{p_end}

{synopt :{cmd:line}}plot cumulative effect as a line graph instead of a bar graph.{p_end}

{synopt :{cmd:*}}options for the plot ({help twoway_options}).{p_end}
{synoptline}


{title:Contents}

{p 4}{help lrplot##description:Description}{p_end}
{p 4}{help lrplot##examples:Examples}{p_end}
{p 4}{help lrplot##author:Author}{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:lrplot} estimates and plots the period-specific and long-run effects of an autoregressive distributed lag (ARDL) model.
{cmd:lrplot} simulates the effects by taking draws from a multivariate normal distribution where the means of each variable 
are the coefficients from the regression and the variance–covariance matrix is the variance–covariance matrix stored in e(V).
{cmd:lrplot} works with any program as long as Stata's time series operators are used ({help tsvarlist}), and the program stores
the coefficients and variance-covariance matrix in e(b) and e(V). {cmd:lrplot} replaces the current dataset with the simulated data and 
the estimated effects by time period.


{marker examples}{...}
{title:Examples}

{pstd}
{cmd:lrplot} produces a table and a plot of the effects. It is important to note that the effects estimated by {cmd:lrplot} 
will differ from those calculated with the {help nlcom} command following estimation. This is because the effects estimated
by {cmd:lrplot} are based on simulations. This also means that a seed must be set to reproduce results. 


{p 4}1.	Estimate an ARDL(1,0) with {cmd:regress}

{p 8}{cmd:reg y l.y x}

{p 8}{cmd:lrplot x}

{p 4}2.	Estimate an ARDL(1,1) with {cmd:xtreg, fe} over 50 time periods

{p 8}{cmd:xtreg l(0/1).(y x), fe}

{p 8}{cmd:lrplot x, time(50)}

{p 4}3.	Estimate an ARDL with a more complex lag structure and a seed to reproduce results

{p 8}{cmd:xtreg y l2.y l3.y x l.x l5.x, fe}

{p 8}{cmd:lrplot x, seed(3424)}

{p 4}4.	Plot the cumulative effect with a line graph instead of a bar graph with a custom x-axis title.

{p 8}{cmd:xtreg y l1.y l2.y x i.time, fe}

{p 8}{cmd:lrplot x, time(75) seed(3424) line xtitle("Year")}

{p 4}5.	lrplot also supports finite distributed lag models (only lags of x appear in the model)

{p 8}{cmd:reghdfe y l(0/4).x, a(id time)}

{p 8}{cmd:lrplot x, sims(1000)}


{marker values}{...}
{title:Saved Values}

{pstd}
{cmd:lrplot} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}    
{synopt:{cmd:r(table)}}matrix containing the period and cumulative effects and their confidence intervals{p_end}

{marker author}{...}
{title:Author}

{pstd}
Ryan Thombs, Boston University, {browse "https://ryanthombs.com/"}