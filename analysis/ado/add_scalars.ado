
capture program drop add_scalars
program define add_scalars
    syntax [, w_electoral]
    
    qui estadd ysumm, replace
    
    // Test time fixed effects
    qui testparm i.year i.parl
    qui estadd scalar time_p = r(p), replace
    TestStatSig `r(F)' `r(p)'
    qui estadd local time_F "`r(StatStars)'", replace
    
    // Test individual fixed effects
    qui testparm $ind
    qui estadd scalar ind_p = r(p), replace
    TestStatSig `r(F)' `r(p)'
    qui estadd local ind_F "`r(StatStars)'", replace
    
    // Test article controls
    qui testparm $article
    qui estadd scalar art_p = r(p), replace
    TestStatSig `r(F)' `r(p)'
    qui estadd local art_F "`r(StatStars)'", replace
    
    // Test topic controls
    qui testparm $topics
    qui estadd scalar topic_p = r(p), replace
    TestStatSig `r(F)' `r(p)'
    qui estadd local topic_F "`r(StatStars)'", replace
    
    // Test minister controls
    qui testparm $min
    qui estadd scalar min_p = r(p), replace
    TestStatSig `r(F)' `r(p)'
    qui estadd local min_F "`r(StatStars)'", replace
    
    // Test electoral controls if specified
    if "`w_electoral'" != "" {
        qui testparm $electoral
        qui estadd scalar elec_p = r(p), replace
        TestStatSig `r(F)' `r(p)'
        qui estadd local elec_F = "`r(StatStars)'", replace
    }
    
    // Format number of observations
    local nobs: display %9.0fc `e(N)'
    estadd local nobs = "\multicolumn{1}{c}{`nobs'}", replace
end
