cap log close
local log ./logs/table3
log using `log'.smcl, replace smcl

do init.do

tictoc tic 1
assert_macros "length_s base_controls article min electoral"

eststo: reg ss1_quote_to_speech i.opposition $length_s $base_controls $min, vce(cluster article_id)
	add_scalars

eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls $min $electoral, vce(cluster article_id)
	add_scalars, w_electoral
			
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls $min, vce(cluster article_id)
	add_scalars
	
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls $min $electoral, vce(cluster article_id)
	add_scalars, w_electoral

eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls $min, vce(cluster article_id)
	add_scalars

eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls $min $electoral, vce(cluster article_id)
	add_scalars, w_electoral

#delimit;
local esttab_options 
	b(%9.3fc)
	se(%9.3fc)
	star (* 0.1 ** 0.05 *** 0.01)
	scalars(
		"time_F F-statistic, time fixed-effects" 
		"ind_F F-statistic, individual controls" 
		"topic_F F-statistic, topic controls" 
		"min_F F-statistic, ministerial controls" 
		"elec_F F-statistic, electoral controls" 
		"ymean Mean of dependent variable"
		"nobs N"
	)
	label
	noobs
	nobase
	noomitted
	nomtitle
	nonumbers
	nolines
	nogaps
	collabels(, none)
	varwidth(17)
	modelwidth(15)
	interaction(*)
	alignment(D{.}{.}{-1})
	substitute(\_ _)
;

esttab,
		coeflabel($coeff_labels)
		`esttab_options'
		keep(1.opposition)
		indicate(
			"Time fixed-effects=*year"
			"Individual controls=*gender *race age* tenure*"
			"Article controls=*weekday *section2 translations"
			"Topic controls=speech_92* quote_92* article_40*"
			"Ministerial controls=*rank $portfolio"
			"Electoral controls=group_size voters vote_share winners_majority_share"
		)
		r2
		compress
		title(Table: Main results for quote-article-speech level)
;

esttab using $TABSAVEDIR/main-quote-lvl-estimates-fragment.tex,
	replace
	fragment
	booktabs
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	sfmt(%9.1f)
	indicate(
		"Time fixed-effects=*year"
		"Individual controls=*gender *race age* tenure*"
		"Article controls=*weekday *section2 translations"
		"Topic controls=speech_92* quote_92* article_40*"
		"Ministerial controls=*rank $portfolio"
		"Electoral controls=group_size voters vote_share winners_majority_share", 
		labels(\multicolumn{1}{c}{\checkmark} \multicolumn{1}{c}{\text{--}} )
	)
	r2
;

esttab using $TABSAVEDIR/main-quote-lvl-estimates-fragment.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	r2
	indicate(
		"Time fixed-effects=*year"
		"Individual controls=*gender *race age* tenure*"
		"Article controls=*weekday *section2 translations"
		"Topic controls=speech_92* quote_92* article_40*"
		"Ministerial controls=*rank $portfolio"
		"Electoral controls=group_size voters vote_share winners_majority_share", 
		labels(x)
	)
	noobs
	scalars(
		"time_F F-statistic, time fixed-effects" 
		"ind_F F-statistic, individual controls" 
		"topic_F F-statistic, topic controls" 
		"min_F F-statistic, ministerial controls" 
		"elec_F F-statistic, electoral controls" 
		"ymean Mean of dependent variable"
		"nobs N"
	)	
    mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)")
;
#delimit cr

tictoc toc 1
beepme 2
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
