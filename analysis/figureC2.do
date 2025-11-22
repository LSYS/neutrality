cap log close
local log ./logs/figureC2
log using `log'.smcl, replace smcl

do init.do

preserve
drop if rank==12  // drop non partisans

cap graph drop byyear byparl

#delimit;
catplot, 
	over(opposition) over(year)
	stack asyvars  percent(year)
	blabel(bar, pos(inside) gap(third_tiny) size(3) format(%2.1f) ) intensity(*0.77)
	legend(label(1 "Government Party") label(2 "Opposition")) graphregion(color(gs16))
	name(byyear)
;
savefig, path($FIGSAVEDIR/partyyear-count) format($graphformats) override(width(1200));

catplot, 
	over(opposition) over(parl)
	stack asyvars  percent(parl)
	blabel(bar, pos(inside) gap(third_tiny) size(4) format(%2.1f) ) intensity(*0.77)
	legend(label(1 "Government Party") label(2 "Opposition")) graphregion(color(gs16))
	name(byparl)
;
savefig, path($FIGSAVEDIR/partyparl-count) format($graphformats) override(width(1200));

#delimit cr
restore

log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
