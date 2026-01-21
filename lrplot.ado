*Author: Ryan Thombs

capture program drop lrplot
program define lrplot, rclass 
        version 15
        syntax varlist(max=1), [time(integer 10) sims(integer 10000) seed(string) level(integer 95) line *]


				
loc dv = e(depvar) // grab DV for ARDL 


if strmatch("`dv'","`varlist'") == 1  {
di as error "Dependent variable cannot be included in varlist."
exit 198
}


if strmatch("`dve'","`varlist'") == 1  {
di as error "Dependent variable cannot be included in varlist."
exit 198
}
		

		
*****SET UP b AND V MATRICES****************************	
tempname b 
tempname V 

mat `b' = e(b)
loc names : colnames `b' 
loc names = subinstr("`names'", "L.", "L1.", .)
loc names = subinstr("`names'", ".", "_", .)
loc names = subinstr("`names'", "_cons", "cons", .)
foreach v of local names {
	local iv `iv' b_`v'
}
mat colnames `b' = `iv'

 

mat `V' = e(V)
mat colnames `V' = `iv'
loc rnames : rownames `V' 
loc rnames = subinstr("`rnames'", ".", "_", .)
loc rnames = subinstr("`rnames'", "_cons", "cons", .)
foreach v of local rnames {
	local iv2 `iv2' b_`v'
}
mat rownames `V' = `iv2'

************************************************


loc x `varlist' // variable of interest




*****COLLECT ALL Y & X************************
loc yall 

foreach v of local iv {
  if strmatch("`v'","b_L*_`dv'") == 1 & strmatch("`v'","b_L*D_`dv'") == 0 local yall `yall' `v' 
}


loc xall 

foreach v of local iv {
  if strmatch("`v'","b_L*_`x'") == 1 & strmatch("`v'","b_L*D_`x'") == 0 local xall `xall' `v' 
}




*****LONG-RUN EFFECT************************
loc y_lr = subinstr("`yall'", " ", "-", .)
loc x_lr b_`x' `xall'
loc x_lr = subinstr("`x_lr'", " ", "+", .)
********************************************

 

**********************************************



*****NUM. Y & X LAGS**************************
loc ylags `yall'

loc ylags = subinstr("`ylags'", "b_L_", "L1_", .)
loc ylags = subinstr("`ylags'", "_`dv'", "", .)
loc ylags = subinstr("`ylags'", "b_L", "", .)
loc ylags = subinstr("`ylags'", "L", "", .)


loc xlags `xall'

loc xlags = subinstr("`xlags'", "b_L_", "L1_", .)
loc xlags = subinstr("`xlags'", "_`x'", "", .)
loc xlags = subinstr("`xlags'", "b_L", "", .)
loc xlags = subinstr("`xlags'", "L", "", .)


******************************************




*****BUILD PERIOD BY PERIOD EQUATIONS**********
foreach j of local ylags {
forval i = `j'/`time' {
	loc k = `i' - `j'
	loc dlag`i' `dlag`i'' b_L`j'_`dv'*t`k' 
	loc dlag`i' = subinstr("`dlag`i''", " ", "+", .)
	}
}


foreach i of local xlags {
	loc xlag`i' `xlag`i''+ b_L`i'_`varlist'*1 
		if "`ylags'" == "" {
			loc xlag`i' = subinstr("`xlag`i''", "+", "", 1)
	}
		if "`dlag`i''" == "" {
			loc xlag`i' = subinstr("`xlag`i''", "+", "", 1)
	}
	
}




loc eq0 b_`x'  

forval i = 1/`time' {
	
	loc eq`i' `dlag`i'' `xlag`i''
	
}




*****GET CONFIDENCE INTERVAL**********

if "`level'" != ""        {                                               
        scalar level = `level'
}
else    {
        scalar level = 95
}
loc ll = (100-level)/2
loc ul = 100-((100-level)/2)

if `level' > 100 {
	    di in r _n "level must be less than 100."
        exit 198
}

***************************************




*****SIMULATIONS********

if "`seed'" != "" {
      loc seed "seed(`seed')"
    }


qui drawnorm `iv', means(`b') cov(`V') n(`sims') `seed'



loc denom -`y_lr'
if "`ylags'" == "" {
	loc denom 
}


qui gen lr = (`x_lr')/(1`denom')  
qui sum lr
loc lr:di %9.4f r(mean)


		di ""
		di as text "{hline 76}" 
        di as text _col(2) "Time" _col(8) "Per. Eff." _col(20) "[`level'% Conf. Interval]" _col(45) "Cum. Eff." _col(57) "[`level'% Conf. Interval]"
		di as text "{hline 76}" 

mat t = J(`time',7,.)

qui gen t0 = `eq0'
qui sum t0
mat t[1,1] = r(mean)
mat t[1,4] = r(mean)
qui _pctile t0, p(`ll' `ul')
mat t[1,2] = r(r1)
mat t[1,3] = r(r2)
mat t[1,5] = r(r1)
mat t[1,6] = r(r2)
mat t[1,7] = 0

loc pe = t[1,1]
loc pell = t[1,2]
loc peul = t[1,3]
loc cum = t[1,4]
loc cumll = t[1,5]	
loc cumul = t[1,6]

	di as result _col(2) t[1,7] _col(5)%9.4f `pe' _col(17)%9.4f `pell' _col(31)%9.4f `peul' _col(42)%9.4f `cum' _col(54)%9.4f `cumll' _col(68)%9.4f `cumul'

tempvar a 
qui gen `a' = t0

loc max = `time' - 1

forval i = 1/`max'  {
	
	loc j = `i' - 1
	loc r = `i' + 1
	
	if "`eq`i''" != "" {
		qui gen t`i' = `eq`i''
	}
	else {
		qui gen t`i' = 0
	}
	qui sum t`i'
	mat t[`r',1] = r(mean)
	mat t[`r',4] = r(mean) + t[`i',4]
	qui _pctile t`i', p(`ll' `ul')
	mat t[`r',2] = r(r1)
	mat t[`r',3] = r(r2)
	
	qui replace `a' = `a'+ t`i'
	qui sum `a'
	qui _pctile `a', p(`ll' `ul')
	mat t[`r',5] = r(r1)
	mat t[`r',6] = r(r2)
	mat t[`r',7] = `i'
	
	loc pe = t[`r',1]
	loc pell = t[`r',2]
	loc peul = t[`r',3]
	loc cum = t[`r',4]
	loc cumll = t[`r',5]
	loc cumul = t[`r',6]
	
	
	di as result _col(2) t[`r',7] _col(5)%9.4f `pe' _col(17)%9.4f `pell' _col(31)%9.4f `peul' _col(42)%9.4f `cum' _col(54)%9.4f `cumll' _col(68)%9.4f `cumul'
	
}
		di as text "{hline 76}" 
		di in smcl as text _col(2) "Long-Run Effect = " as res %6.4f `lr' 
		di as text "{hline 76}" 


mat colnames t = teffect tll tul cum cll cul t // give matrix t column names
svmat t, names(col) // creates variables based on matrix columns 
 


if "`line'" != "" {
twoway (line cum t, fcolor("gs12%40")) (rarea cll cul t, fintensity(50) fcolor("199 199 199%40") lwidth(none)) (line teffect t, lwidth(.7) lcolor("214 39 40")) (rarea tll tul t, fintensity(50) fcolor("214 39 40%40") lwidth(none)), xtitle("Time") legend(order(1 "Cum. Eff." 2 "`level'% CI" 3 "Per. Eff." 4 "`level'% CI") col(1) size(3.5) region(lcolor(black) fcolor(white) lstyle(solid))) graphregion(margin(medlarge)) plotregion(margin(zero)) `options'
}
else {
twoway (bar cum t, fcolor("gs12%40")) (rbar cll cul t if t>0, barwidth(.1) lwidth(medium) bcolor("127 127 127") fcolor("199 199 199")) (line teffect t, lwidth(.7) lcolor("214 39 40")) (rarea tll tul t, fintensity(50) fcolor("214 39 40%40") lwidth(none)), xtitle("Time")  legend(order(1 "Cum. Eff." 2 "`level'% CI" 3 "Per. Eff." 4 "`level'% CI") col(1) size(3.5) region(lcolor(black) fcolor(white) lstyle(solid))) graphregion(margin(medlarge)) plotregion(margin(zero)) `options'
}

return matrix table t








end 


