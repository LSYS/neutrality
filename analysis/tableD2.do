cap log close
local log ./logs/table3
log using `log'.smcl, replace smcl

do init.do

tictoc tic 1
assert_macros "objectivity polarity readability"

pca $objectivity
predict pc1_objectivity, score
label variable pc1_objectivity	"1st PC of objectivity scores"

pca $polarity
predict pc1_polarity, score
label variable pc1_polarity 	"1st PC of polarity scores"

pca $readability
predict pc1_readability, score
label variable pc1_readability 	"1st PC of readability scores"

pca cttr msttr mattr mtld hdd maas // rttr and cttr are perfectly correlated, so rttr is removed, herdan, ttr, and summer are removed because their kmo < 0.5
predict pc1_lexical, score
label variable pc1_lexical 		"1st PC of lexical richness scores"


assert_macros "length_s base_controls_min"
*--------------------------------------------------------------------------------------------------
* Panel A. String simlarity 1 with PC controls
*--------------------------------------------------------------------------------------------------
eststo clear

eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min, 														    vce(cluster article_id) 
eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min pc1_objectivity, 										    vce(cluster article_id) 
eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min 				  pc1_polarity, 							vce(cluster article_id) 
eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min 							   pc1_readability, 			vce(cluster article_id) 
eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min 											   pc1_lexical, vce(cluster article_id) 
eststo: qui reg ss1_quote_to_speech i.opposition $length_s $base_controls_min pc1_objectivity pc1_polarity pc1_readability pc1_lexical, vce(cluster article_id) 

#delimit ;
esttab, keep(
			1.opposition
			pc1_objectivity
			pc1_polarity
			pc1_readability
			pc1_lexical
		)
		coeflabel(`my_coeflabel')
		`esttab_options'
		order(`keep_coeff') 
;

esttab using $TABSAVEDIR/add-linguistics-panelA-substring-accuracy.tex, 	
	replace
	booktabs
	fragment
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
	b(%9.2fc)
	se(%9.2fc)
	star (* 0.1 ** 0.05 *** 0.01)
	label
	noobs
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
;

esttab using $TABSAVEDIR/add-linguistics-panelA-substring-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
    mtitle("(1) Baseline" "(2) +Objectivity" "(3) +Polarity" "(4) +Readability" "(5) +Lexical" "(6) +All")
;
#delimit cr			

*--------------------------------------------------------------------------------------------------
* Panel B. String similarity 2 with PC controls
*--------------------------------------------------------------------------------------------------
eststo clear

eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min, 														    vce(cluster article_id) 
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min pc1_objectivity, 										    vce(cluster article_id) 
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min 				  pc1_polarity, 							vce(cluster article_id) 
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min 							   pc1_readability, 			vce(cluster article_id) 
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min 											   pc1_lexical, vce(cluster article_id) 
eststo: qui reg ss2_quote_to_speech i.opposition $length_s $base_controls_min pc1_objectivity pc1_polarity pc1_readability pc1_lexical, vce(cluster article_id) 

#delimit ;
esttab, keep(
			1.opposition
			pc1_objectivity
			pc1_polarity
			pc1_readability
			pc1_lexical
		)
		coeflabel(`my_coeflabel')
		`esttab_options'
		order(`keep_coeff') 
;

esttab using $TABSAVEDIR/add-linguistics-panelB-bow-accuracy.tex, 	
	replace
	booktabs
	fragment
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
	b(%9.2fc)
	se(%9.2fc)
	star (* 0.1 ** 0.05 *** 0.01)
	label
	noobs
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
;

esttab using $TABSAVEDIR/add-linguistics-panelB-bow-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
    mtitle("(1) Baseline" "(2) +Objectivity" "(3) +Polarity" "(4) +Readability" "(5) +Lexical" "(6) +All")
;
#delimit cr			

*--------------------------------------------------------------------------------------------------
* Panel C. Semantic similarity with PC controls
*--------------------------------------------------------------------------------------------------
eststo clear
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min, 														    vce(cluster article_id)
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min pc1_objectivity, 										    vce(cluster article_id)
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min 				  pc1_polarity, 							vce(cluster article_id)
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min 							   pc1_readability, 			vce(cluster article_id)
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min 											   pc1_lexical, vce(cluster article_id)
eststo: qui reg ce_max_quote2speech i.opposition $length_s $base_controls_min pc1_objectivity pc1_polarity pc1_readability pc1_lexical, vce(cluster article_id)

#delimit ;
esttab, keep(
			1.opposition
			pc1_objectivity
			pc1_polarity
			pc1_readability
			pc1_lexical
		)		coeflabel(`my_coeflabel')
		`esttab_options'
		order(`keep_coeff')
;

esttab using $TABSAVEDIR/add-linguistics-panelC-semantic-accuracy.tex,
	replace
	booktabs
	fragment
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
	b(%9.2fc)
	se(%9.2fc)
	star (* 0.1 ** 0.05 *** 0.01)
	label
	noobs
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
;
esttab using $TABSAVEDIR/add-linguistics-panelC-semantic-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(
		1.opposition
		pc1_objectivity
		pc1_polarity
		pc1_readability
		pc1_lexical
	)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
    mtitle("(1) Baseline" "(2) +Objectivity" "(3) +Polarity" "(4) +Readability" "(5) +Lexical" "(6) +All")
;
#delimit cr


tictoc toc 1
beepme 2
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
