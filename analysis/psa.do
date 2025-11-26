do init.do

tictoc tic 1
assert_macros "length_s time topics article min ind"

* Estimated treatment effect of Opposition status on quote accuracy, if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.180
*       is -2.88 (compared to -1.86)
psacalc beta opposition, ///
	rmax(0.234) /// 
	delta(1) ///
	model(reg ss1_quote_to_speech $length_s $time $topics $ind $min $article opposition)


* For the treatment effect of Opposition status on quote accuracy to be zero, 
*       unobservables would need to be approximately 15.7 times more important 
*       than observables
psacalc delta opposition, ///
	rmax(0.234) /// 
	beta(0) ///
	model(reg ss1_quote_to_speech $length_s $time $topics $ind $min $article opposition)

* Estimated treatment effect of Opposition status on quote accuracy (BoW), if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.110
*       is -2.78 (compared to -2.15)
psacalc beta opposition, ///
	rmax(0.143) /// 
	delta(1) ///
	model(reg ss2_quote_to_speech $length_s $time $topics $ind $min $article opposition)

* For the treatment effect of Opposition status on quote accuracy (BoW) to be zero, 
*       unobservables would need to be approximately 8.3 times more important 
*       than observables
psacalc delta opposition, ///
	rmax(0.143) /// 
	beta(0) ///
	model(reg ss2_quote_to_speech $length_s $time $topics $ind $min $article opposition)	


* Estimated treatment effect of Opposition status on semantic accuracy, if there is equal selection b/w
*       observables and unobservables, conditional on length, time FE, topics, individual controls, 
*       ministerial controls, article controls, and objectivity, sentiment, readability, and lexical richness
*       with rmax set 1.3 times of 0.230
*       is -7.04 (compared to -4.05)
psacalc beta opposition, ///
	rmax(0.299) /// 
	delta(1) ///
	model(reg ce_max_quote2speech $length_s $time $topics $ind $min $article opposition)

* For the treatment effect of Opposition status on semantic accuracy to be zero, 
*       unobservables would need to work in the OPPOSITE direction from observables,
*       with selection on unobservables being approximately 4.9 times as strong
*       (but opposite in sign) compared to selection on observables
psacalc delta opposition, ///
	rmax(0.299) /// 
	beta(0) ///
	model(reg ce_max_quote2speech $length_s $time $topics $ind $min $article opposition)	

tictoc toc 1
