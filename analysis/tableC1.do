cap log close
local log ./logs/tableC1
log using `log'.smcl, replace smcl

do init.do

tictoc tic 1
assert_macros "portfolio topics base_controls min electoral"

preserve
collapse	(sum) quote quote_char ///
			(count) fragments = quote ///
			(first) opposition ///
			(first) speech speech_char ///
			(first) article article_char ///
			(first) parl ///
			(first) gender race age* tenure* ///
			(first) weekday section2 translations ///
			(first) rank $portfolio ///
			(first) group_size voters vote vote_share winners_majority_share ///
			(mean)  $topics ///
			,by(article_id speech_id mp year)

#delimit ;
global log_variables 	"
						quote 
						quote_char 
						speech
						speech_char
						article
						article_char
						";
#delimit cr

foreach var in $log_variables	{
	gen ln_`var' = ln(`var')
	label variable ln_`var' "ln of `var'"
}
							
eststo clear
local length ln_speech ln_article
eststo: reg ln_quote 			i.opposition `length' 	   $base_controls $min,            vce(cluster article_id)
	add_scalars

eststo: reg ln_quote 			i.opposition `length' 	   $base_controls $min $electoral, vce(cluster article_id)
	add_scalars, w_electoral

#delimit ;
esttab, keep(`keep_coeff')
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel A. string similarity 1 robustness checks)
;
esttab using $TABSAVEDIR/main-article-speech-quote-coverage.tex,
	replace 
	fragment
	booktabs
	keep(1.opposition)
	coeflabel($coeff_labels)
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
	varwidth(17)
	modelwidth(15)
	interaction(*)
	alignment(D{.}{.}{-1})
	substitute(\_ _)
	indicate(
		"Time fixed-effects=*year"
		"Individual controls=*gender *race age* tenure*"
		"Article controls=*weekday *section2 translations"
		"Topic controls=speech_92* quote_92* article_40*"
		"Ministerial controls=*rank $portfolio"
		"Electoral controls=group_size voters vote_share winners_majority_share", 
		labels(\checkmark \text{--})
	)
	r2
;

esttab using $TABSAVEDIR/main-article-speech-quote-coverage.md,
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
    mtitle("(1)" "(2)")
;
#delimit cr
restore


tictoc toc 1
beepme 2
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
