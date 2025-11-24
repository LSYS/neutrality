
cap log close
local log ./logs/figureD2-estimates
log using `log'.smcl, replace smcl

do ./init.do

tictoc tic 1

global outcome 		ce_max_quote2speech
global length		ln_paragraph ln_speech ln_article
global time 		i.parl i.year
global ind 			i.gender i.race c.age c.age2 c.tenure c.tenure2
global article 		i.weekday i.section2 translations
global portfolio 	MFA PMO MEWR MCI MTI MHA MCCY MinLaw MOH MOM MinDef MSF MOT MND MOF MOE speaker
global electoral	c.group_size c.voters c.vote c.vote_share c.winners_majority c.winners_majority_share


global maintopics		speech_92K* quote_92K* article_40K*
global alttopics		speech_50K* quote_50K* article_30K*

assert_macros "time length maintopics ind article portfolio"
local SAVEPATH ./figureD2/specest-semantic

* main is full interaction of portfolio, but no electoral controls
qui reg $outcome $time $length $maintopics $ind $article ($portfolio)##i.rank opposition, vce(cluster article_id)
specchart opposition,spec(main $outcome time length topic5 ind article portfolio rank portfoliorank) file(`SAVEPATH') replace

* Loop over accuracy type
foreach y of varlist $outcome {
	foreach i of num 1/9 { /* Loop over topic combinations */
		if "`i'"=="1" { /* speechK=50 articleK=30 */
			global topictype speech_50K* quote_50K* article_30K*
			local topictype topic`i'
		}
		else if "`i'"=="2" { /* speechK=50 articleK=40 */
			global topictype speech_50K* quote_50K* article_40K*
			local topictype topic`i'
		}
		else if "`i'"=="3" { /* speechK=50 articleK=50 */
			global topictype speech_50K* quote_50K* article_50K*
			local topictype topic`i'
		}
		else if "`i'"=="4" { /* speechK=92 articleK=30 */
			global topictype speech_92K* quote_92K* article_30K*
			local topictype topic`i'
		}
		else if "`i'"=="5" { /* speechK=92 articleK=40 */
			global topictype speech_92K* quote_92K* article_40K*
			local topictype topic`i'
		}
		else if "`i'"=="6" { /* speechK=92 articleK=50 */
			global topictype speech_92K* quote_92K* article_50K*
			local topictype topic`i'
		}
		else if "`i'"=="7" { /* speechK=100 articleK=30 */
			global topictype speech_100K* quote_100K* article_30K*
			local topictype topic`i'
		}
		else if "`i'"=="8" { /* speechK=100 articleK=30 */
			global topictype speech_100K* quote_100K* article_40K*
			local topictype topic`i'
		}
		else if "`i'"=="9" { /* speechK=100 articleK=30 */
			global topictype speech_100K* quote_100K* article_50K*
			local topictype topic`i'
		}
		* (1) Main spec, in terms of covariates
		qui reg `y' $time $length $topictype $ind $article ($portfolio)##i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind article portfolio rank portfoliorank) file(`SAVEPATH')		

		* (2) No Ind controls
		qui reg `y' $time $length $topictype $article ($portfolio)##i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' article portfolio rank portfoliorank) file(`SAVEPATH') 		

		* (3) No length controls
		qui reg `y' $time $topictype $ind $article ($portfolio)##i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time `topictype' ind article portfolio rank portfoliorank) file(`SAVEPATH') 		

		* (4) No article controls
		qui reg `y' $time $length $topictype $ind ($portfolio)##i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind portfolio rank portfoliorank) file(`SAVEPATH')		

		* (5) No portfolio
		qui reg `y' $time $length $topictype $ind $article i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind article rank) file(`SAVEPATH')		

		* (6) No Rank
		qui reg `y' $time $length $topictype $ind $article $portfolio opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind article portfolio) file(`SAVEPATH')	

		* (7) No portfolio + rank interaction
		qui reg `y' $time $length $topictype $ind $article $portfolio i.rank opposition, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind article portfolio rank) file(`SAVEPATH')	

		* (8) + electoral
		qui reg `y' $time $length $topictype $ind $article ($portfolio)##i.rank opposition $electoral, vce(cluster article_id)
		specchart  opposition,spec(`y' time length `topictype' ind article portfolio rank portfoliorank elec) file(`SAVEPATH')		
	}
}

tictoc toc 1
beepme 3
log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
