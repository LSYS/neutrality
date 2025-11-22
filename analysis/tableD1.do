cap log close
local log ./logs/tableD1
log using `log'.smcl, replace smcl

do init.do

tictoc tic 1

*==================================================================================================
* Table: Robustness checks for string similarity measures
* Panel A. string similarity 1 robustness checks
* Panel B. string similarity 1 (no stopwords) robustness checks
* Panel C. string similarity 2 robustness checks
* Panel D. string similarity 2 (no stopwords) robustness checks
*==================================================================================================							
#delimit ;	
local esttab_options "b(%9.2fc)
					 se(%9.2fc)
					 star (* 0.1 ** 0.05 *** 0.01)
					 label
					 noobs
					 varwidth(10)
					 modelwidth(14)
					 interaction(*)";
					 
local keep_coeff 	"
					1.opposition 
					";
					
local model_title	"
					"Base"
					"Author FE"
					"$\sim$ministerial"
					"$\sim$translations"
					"Cluster speech"					
					"Cluster author"
					"Speech K=50"
					"Speech K=100"
					"Article K=30"
					"Article K=50"
					"SentenceK"
					";
#delimit cr

assert_macros "time ind article min"
local base quote paragraph speech article $time $ind $article

*--------------------------------------------------------------------------------------------------
* Panel A. string similarity 1 robustness checks
*--------------------------------------------------------------------------------------------------
eststo clear

eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss1_quote_to_speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"

#delimit ;
esttab, keep(1.opposition)
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel A. string similarity 1 robustness checks)
;
esttab using $TABSAVEDIR/sensitivity-panelA-substring-accuracy.tex,
	replace
	booktabs
	fragment
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelA-substring-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr

// *--------------------------------------------------------------------------------------------------
// * Panel B. string similarity 1 (no stopwords) robustness checks
// *--------------------------------------------------------------------------------------------------
eststo clear
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss1_quote_to_speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"

#delimit ;
esttab, keep(1.opposition)
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel B)
;
esttab using $TABSAVEDIR/sensitivity-panelB-substring-accuracy-nostopwords.tex,
	replace
	booktabs
	fragment
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelB-substring-accuracy-nostopwords.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr

// *--------------------------------------------------------------------------------------------------
// * Panel C. string similarity 2 robustness checks
// *--------------------------------------------------------------------------------------------------
eststo clear
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ss2_quote_to_speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"

#delimit ;
esttab, keep(1.opposition)
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel C)
;
esttab using $TABSAVEDIR/sensitivity-panelC-bow-accuracy.tex,
	replace
	booktabs
	fragment
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelC-bow-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr
			
// *--------------------------------------------------------------------------------------------------
// * Panel D. string similarity 2 (no stopwords) robustness checks
// *--------------------------------------------------------------------------------------------------
eststo clear
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg _ss2_quote_to_speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"

#delimit ;
esttab, keep(`keep_coeff')
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel D)
;
esttab using $TABSAVEDIR/sensitivity-panelD-bow-accuracy-nostopwords.tex,
	replace
	booktabs
	fragment
	keep(`keep_coeff')
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelD-bow-accuracy-nostopwords.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr

// *--------------------------------------------------------------------------------------------------
// * Panel E. Semantic similarity robustness checks
// *--------------------------------------------------------------------------------------------------
eststo clear
eststo: reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg ce_max_quote2speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"


#delimit ;
esttab, keep(1.opposition)
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel E)
;
esttab using $TABSAVEDIR/sensitivity-panelE-semantic-accuracy.tex,
	replace
	booktabs
	fragment
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelE-semantic-accuracy.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr


// *--------------------------------------------------------------------------------------------------
// * Panel F. Semantic similarity robustness checks (Binarized)
// *--------------------------------------------------------------------------------------------------
foreach val in 90 95 99 {
    count if ce_max_quote2speech <= `val'
    local pct = (r(N)/_N) * 100
    display "Value `val' is at the `pct'th percentile"
}

gen dce_max_quote2speech = (ce_max_quote2speech >= 99) if !missing(ce_max_quote2speech)

eststo clear
eststo: reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2 i.beat, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base'      speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* if translations==0, vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K*,          vce(cluster speech_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* quote_92K* i.author2,vce(cluster author2)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_50K*  article_40K* quote_50K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_100K* article_40K* quote_100K*,         vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_30K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_50K* quote_92K*,          vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_92K*  article_40K* sentence_92K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"
eststo: qui reg dce_max_quote2speech i.opposition `base' $min speech_50K*  article_30K* quote_50K*,       vce(cluster article_id)
	local nobs: display %9.0fc `e(N)'
	estadd local nobs = "\multicolumn{1}{c}{`nobs'}"


#delimit ;
esttab, keep(1.opposition)
		coeflabel(`my_coeflabel')
		scalars("df_m df-model" "clustvar cluster-variable" "N_clust cluster-N")
		`esttab_options'
		mtitles(`model_title')
		title(Panel E)
;
esttab using $TABSAVEDIR/sensitivity-panelF-semantic-accuracy-binarized99.tex,
	replace
	booktabs
	fragment
	keep(1.opposition)
	coeflabel($coeff_labels)
	`esttab_options'
	nomtitle
	nonumbers
	nolines
	nogaps
	noeqlines
	nodepvars
	scalars("nobs N")
;
esttab using $TABSAVEDIR/sensitivity-panelF-semantic-accuracy-binarized99.md,
	replace
	se
	star (* 0.1 ** 0.05 *** 0.01)
	keep(1.opposition)
	coeflabel($coeff_labels)
    b(%9.2f)
    se(%9.2f)
    nonumbers
	style(mmd)
	mtitle(
	    "(1) Baseline Regression"
	    "(2) Journalist FE"
	    "(3) No ministerial controls"
	    "(4) No translations"
	    "(5) Cluster by speech"
	    "(6) Cluster by journalist"
	    "(7) Speech K = 50"
	    "(8) Speech K = 100"
	    "(9) Article K = 30"
	    "(10) Article K = 50"
	    "(11) Sentence topics"
	    "(12) Parsimonious topics"
	)	
;
#delimit cr

tictoc toc 1
beepme 3
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
