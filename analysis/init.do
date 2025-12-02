cls 					// Clear results window
clear all               // Start with a clean slate
set more off, perm      // Disable partitioned output
macro drop _all         // Clear all macros to avoid namespace conflicts
set linesize 150        // Line size limit to make output more readable, affects logs
set varabbrev off, perm // Turn off variable abbreviation
// pause on                // Enable pause mode for debugging
version 13.1            // Set Stata version to 13.1
set matsize 10000

*==============================================================================
// Set root path
// cap net install here, from("https://raw.githubusercontent.com/korenmiklos/here/master/")
cap here
if _rc == 0 {
	here, set
	cd ${here}
}
else {
	global here "\\wsl.localhost\Debian\home\lsys\neutrality\analysis"
	cd $here
}

*==============================================================================
// Point to ado programs
adopath ++ ./ado

use "../pipeline/out/media.dta", clear
do preamble

global TABSAVEDIR ../results/tables
global FIGSAVEDIR ../results/figures
global graphformats png pdf eps tif


*==============================================================================
* Global macros
*==============================================================================
#delimit;
global time
	i.parl
	i.year
;
global ind
    i.gender
    i.race
    c.age
    c.age2
    c.tenure
    c.tenure2
;
    
global article
    i.weekday
    i.section2
    translations
;
    
global portfolio
    MFA
    PMO
    MEWR
    MCI
    MTI
    MHA
    MCCY
    MinLaw
    MOH
    MOM
    MinDef
    MSF
    MOT
    MND
    MOF
    MOE
    speaker
;
    
global electoral
    c.group_size
    c.voters
    c.vote_share
    c.winners_majority_share
;
    
global topics
    speech_92K*
    quote_92K*
    article_40K*
;
    
global objectivity
    speech_objectivity
    para_objectivity
    sentence_objectivity
    quote_objectivity
    quote_sentence_objectivity
;
    
global polarity
    speech_polarity
    para_polarity
    sentence_polarity
    quote_polarity
    quote_sentence_polarity
;
    
global readability
    flesch
    fleschkincaid
    gunningfog
    smog
    dalechall
    notdalechall
    sentences
    syllables
    polysyllable
;
    
global lexical
    ttr
    rttr
    cttr
    herdan
    summer
    dugast
    maas
    msttr
    mattr
    mtld
    hdd
;

global length_s
    ln_quote
    ln_speech
    ln_article
;

assert_macros "portfolio time ind article topics";

global min
    i.rank
    $portfolio
    i.rank#($portfolio)
    ;
    
global base_controls
    $time
    $ind
    $article
    $topics
    ;
    
global base_controls_min
    $time
    $ind
    $article
    $topics
    $min
    ;
#delimit cr

*==============================================================================
* COEFFICIENT LABELS
*==============================================================================
#delimit;
global coeff_labels
	"
    1.opposition "Opposition"
    1.opposition#c.trend "Opposition $\times$ Year"
    trend "Year"
	pc1_objectivity "Objectivity of speech and quote"
	pc1_polarity "Polarity of speech and quote"
	pc1_readability "Grade/readability score of speech transcipt"
	pc1_lexical "Lexical richness of speech transcipt"
    "
;
#delimit cr
