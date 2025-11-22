do init.do

tictoc tic 1
assert_macros "length_s time topics article min ind"

* Estimated treatment effect of Opposition status on quote accuracy, if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.160
*       is -2.11 (compared to -1.47)
psacalc beta opposition, ///
	rmax(0.208) /// 
	delta(1) ///
	model(reg ss1_quote_to_speech $length_s $time $topics $ind $min $article opposition)


* For the treatment effect of Opposition status on quote accuracy to be zero, 
*       unobservables would need to be approximately 102 times more important 
*       than observables (with Rmax = 1.3 × R-squared of 0.160)
psacalc delta opposition, ///
	rmax(0.208) /// 
	beta(0) ///
	model(reg ss1_quote_to_speech $length_s $time $topics $ind $min $article opposition)

* Estimated treatment effect of Opposition status on quote accuracy (BoW), if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.111
*       is -3.12 (compared to -2.34)
psacalc beta opposition, ///
	rmax(0.144) /// 
	delta(1) ///
	model(reg ss2_quote_to_speech $length_s $time $topics $ind $min $article opposition)

* For the treatment effect of Opposition status on quote accuracy (BoW) to be zero, 
*       unobservables would need to be approximately 12 times more important 
*       than observables (with Rmax = 1.3 × R-squared of 0.111)
psacalc delta opposition, ///
	rmax(0.144) /// 
	beta(0) ///
	model(reg ss2_quote_to_speech $length_s $time $topics $ind $min $article opposition)	


* Estimated treatment effect of Opposition status on semantic accuracy, if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.158
*       is -9.27 (compared to -5.36)
psacalc beta opposition, ///
	rmax(0.205) /// 
	delta(1) ///
	model(reg ce_max_quote2speech $length_s $time $topics $ind $min $article opposition)

* For the treatment effect of Opposition status on semantic accuracy to be zero, 
*       unobservables would need to work in the OPPOSITE direction from observables,
*       with selection on unobservables being approximately 4.5 times as strong
*       (but opposite in sign) compared to selection on observables
psacalc delta opposition, ///
	rmax(0.205) /// 
	beta(0) ///
	model(reg ce_max_quote2speech $length_s $time $topics $ind $min $article opposition)	

tictoc toc 1
