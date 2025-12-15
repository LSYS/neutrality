cap log close
local log ./logs/figure3
log using `log'.smcl, replace smcl

do init.do

tictoc tic 1
assert_macros "length_s base_controls min"

grstyle init
grstyle set plain, horizontal nogrid
grstyle set lpattern dash solid

foreach acc of varlist ss1_quote_to_speech ss2_quote_to_speech ce_max_quote2speech {
	reg `acc' i.opposition##i.year $length_s $base_controls $min, vce(cluster article_id)
	margins i.opposition, over(year)

	// plot
	#delimit ;
	marginsplot,
	    level(95)
	    recast(connected)
	    xdimension(year)
	    plot1opts(
	        lcolor(gs10)
	        lwidth(medium) 
	        mcolor(gs15)
	        msize(vlarge)
			mlcolor(gs7)
			mlwidth(thin)       
	  )
	    plot2opts(
	        lcolor("120 141 134")
	        lwidth(medium)
	        mcolor("59 77 71") 
	        msize(vlarge)
			mlcolor(gs7)
			mlwidth(thin)        
	    )
		ci1opts(
			color(gs12)
			lwidth(thin)
		)
		ci2opts(
			color("120 141 134")
			lwidth(thin)
		)	
		legend(
		    order(
		    	2 "Opposition" 
		    	1 `"Ruling party"' `"(baseline)"' 
		    )
		    position(4)
		    ring(0)
		    cols(1)
		    size(huge)
		    region(lstyle(none))
		    bmargin(vsmall)
		)
	    title("")
		ytitle("Model-predicted accuracy", size(huge))
	    xtitle("")
		xlabel(, labsize(vlarge) angle(35) )
		ylabel(60 70 80 90 100, labsize(vlarge))
		yscale(range(54 105))
		plotregion( lstyle(none) lcolor(black)  )
		graphregion( color(white) margin(0 0 0 0) )
		name(`acc')
	;
	#delimit cr
	savefig, path($FIGSAVEDIR/pred-margins-year-`acc') format($graphformats) override(width(1200))

}


beepme 2
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
