*-----------------------------------------------------------------------
* IDENTIFIERS AND METADATA
*-----------------------------------------------------------------------
label var qid         "Quote ID"
label var article_id  "News article ID (title-date tuple)"
label var speech_id   "Speech ID"

label var date        "Publication date"
label var matched_date "Matched speech date"
label var matched_score "Matched score in semi-automated assessing"

label var mp          "MP ID"
label var party       "Party of politician (string code)"
label var opposition  "=1 if from an opposition party"
gen ruling = (party == "pap")
label var ruling  "=1 if from the government party"
label var non_partisan "=1 if non-partisan MP"
assert (1 == opposition + ruling + non_partisan)
label var speaker     "=1 if making speech in capacity of speaker"

label var section     "Original article section"

*======================================================================
* MP CAREER
*======================================================================
label var start "Start date of MP's parliamentary service"
rename _end end
label var end   "End date of MP's parliamentary service"

*--- Rank of MP --------------------------------------------------------
label define rank_label ///
    1 "pm" 2 "dpm" 3 "minister" 4 "sms" 5 "mos" 6 "mayor" 7 "sps" ///
    8 "parl sec" 9 "speaker" 10 "mp" 11 "ncmp" 12 "nmp"
encode rank, gen(mp_rank) label(rank_label)
drop rank
rename mp_rank rank
label var rank "Rank of MP at time of speech"
fvset base 10 rank   // base: Member of Parliament

*--- Tenunre -----------------------------------------------------------
gen _tenure = tenure / 365
drop tenure
rename _tenure tenure
label var tenure "Seniority of politician at time of speech (years)"

gen tenure2 = tenure^2
label var tenure2 "Square of tenure"

*======================================================================
* INDIVIDUAL DEMOGRAPHICS
*======================================================================
label var dob   "Date of birth of MP"
label var yob   "Year of birth of MP"

*--- Gender (0 = male, 1 = female) ------------------------------------
label define gender_label 0 "male" 1 "female"
encode gender, gen(sex) label(gender_label)
drop gender
rename sex gender
fvset base 0 gender
label var gender "Gender of politician"

*--- Race --------------------------------------------------------------
label define race_label 0 "chinese" 1 "malay" 2 "indian" 3 "eurasian"
encode race, gen(ethnic) label(race_label)
drop race
rename ethnic race
fvset base 0 race
label var race "Race of politician (Chinese, Malay, Indian, Eurasian/other)"

*--- Age ---------------------------------------------------------------
gen _age = age / 365
drop age
rename _age age
label var age "Age of politician at time of speech (years)"

gen age2    = age^2
label var age2 "Square of age"

*======================================================================
* MINISTRY
*======================================================================
label var MND    "=1 if speech made while at Ministry of National Development"
label var MinDef "=1 if speech made while at Ministry of Defence"
label var MFA    "=1 if speech made while at Ministry of Foreign Affairs"
label var MinLaw "=1 if speech made while at Ministry of Law"
label var MHA    "=1 if speech made while at Ministry of Home Affairs"
label var MOT    "=1 if speech made while at Ministry of Transport"
label var MOF    "=1 if speech made while at Ministry of Finance"
label var MOM    "=1 if speech made while at Ministry of Manpower"
label var MTI    "=1 if speech made while at Ministry of Trade and Industry"
label var MCCY   "=1 if speech made while at Ministry of Culture, Community and Youth"
label var MSF    "=1 if speech made while at Ministry of Social and Family Development"
label var MOH    "=1 if speech made while at Ministry of Health"
label var PMO    "=1 if speech made while at Prime Minister's Office"
label var MEWR   "=1 if speech made while at Ministry of the Environment and Water Resources"
label var MCI    "=1 if speech made while at Ministry of Communications and Information"
label var MOE    "=1 if speech made while at Ministry of Education"

recode MFA PMO MEWR MCI MTI MHA MCCY MinLaw MOH MOM MinDef MSF MOT MND MOF MOE (. = 0)

*======================================================================
* STRING SIMILARITY AND SEMANTIC MATCHING
*======================================================================

*--- String similarity 1 (partialscore) -------------------------------
rename partialscore_quote_to_fullspeech  ss1_quote_to_speech
label var ss1_quote_to_speech            "String similarity score 1 for quote to speech"

rename partialscore_quote_to_paragraph   ss1_quote_to_paragraph
label var ss1_quote_to_paragraph         "String similarity score 1 for quote to paragraph"

rename partialscore_quote_to_sentence    ss1_quote_to_sentence
label var ss1_quote_to_sentence          "String similarity score 1 for quote to sentence"

rename _partialscore_speech              _ss1_quote_to_speech
label var _ss1_quote_to_speech           "(no stopwords) string similarity score 1 for quote to speech"

rename _partialscore_paragraph           _ss1_quote_to_paragraph
label var _ss1_quote_to_paragraph        "(no stopwords) string similarity score 1 for quote to paragraph"

rename _partialscore_sentence            _ss1_quote_to_sentence
label var _ss1_quote_to_sentence         "(no stopwords) string similarity score 1 for quote to sentence"

*--- String similarity 2 (tokensetscore) ------------------------------
rename tokensetscore_quote_to_sentence   ss2_quote_to_sentence
label var ss2_quote_to_sentence          "String similarity score 2 for quote to sentence"

rename tokensetscore_quote_to_paragraph  ss2_quote_to_paragraph
label var ss2_quote_to_paragraph         "String similarity score 2 for quote to paragraph"

rename tokensetscore_quote_to_fullspeec  ss2_quote_to_speech
label var ss2_quote_to_speech            "String similarity score 2 for quote to speech"

rename tokensetscore_quote_to_sentence_  _ss2_quote_to_sentence
label var _ss2_quote_to_sentence         "(no stopwords) string similarity score 2 for quote to sentence"

rename _0tokensetscore_quote_to_paragra  _ss2_quote_to_paragraph
label var _ss2_quote_to_paragraph        "(no stopwords) string similarity score 2 for quote to paragraph"

rename _1tokensetscore_quote_to_fullspe  _ss2_quote_to_speech
label var _ss2_quote_to_speech           "(no stopwords) string similarity score 2 for quote to speech"

*--- Semantic matching scores -----------------------------------------
replace ce_max_quote2speech = 100 * ce_max_quote2speech
label var be_max_quote2speech "Best embedding-based biencoder score for quote to speech"
label var ce_max_quote2speech "Cross-encoder semantic score for quote to speech (0-100)"

*======================================================================
* CONSTITUENCY AND ELECTORAL VARIABLES
*======================================================================
rename num group_size
label var group_size             "Politician size of constituency (1 to 6)"

label var voters                 "Electoral size of constituency for current parliament"
label var valid_votes            "Number of valid votes in constituency"
label var winners_majority       "Number of votes for winning party/candidate"
label var vote                   "Number of votes for current parliament"
label var vote_share             "Percentage of votes for current parliament"
label var winners_majority_share "Winners' majority share (percent of valid votes)"
label var swing                  "Electoral swing in ruling party vote share (percentage points)"

*======================================================================
* PARLIAMENT, YEAR, ELECTION TIMING, WEEKDAY
*======================================================================
*--- Parliament life: dummies + factor ---------------------------------
label var parl10 "=1 if speech occurred in 10th Parliament"
label var parl11 "=1 if speech occurred in 11th Parliament"
label var parl12 "=1 if speech occurred in 12th Parliament"
label var parl13 "=1 if speech occurred in 13th Parliament"

label define parl_label 0 "10th parliament" 1 "11th parliament" 2 "12th parliament" 3 "13th parliament"
encode parl, gen(parliament) label(parl_label)
drop parl
rename parliament parl
fvset base 0 parl
label var parl "Parliament life (categorical)"

*======================================================================
* ELECTION TIMING INDICATORS
*======================================================================
*--- General elections -------------------------------------------------
label var ge2006       "=1 if article published in year of General Election 2006"
label var ge2011       "=1 if article published in year of General Election 2011"
label var ge2015       "=1 if article published in year of General Election 2015"

label var ge2006_1mth  "=1 if article within 1 month of General Election 2006"
label var ge2006_3mths "=1 if article within 3 months of General Election 2006"
label var ge2006_6mths "=1 if article within 6 months of General Election 2006"

label var ge2011_1mth  "=1 if article within 1 month of General Election 2011"
label var ge2011_3mths "=1 if article within 3 months of General Election 2011"
label var ge2011_6mths "=1 if article within 6 months of General Election 2011"

label var ge2015_1mth  "=1 if article within 1 month of General Election 2015"
label var ge2015_3mths "=1 if article within 3 months of General Election 2015"
label var ge2015_6mths "=1 if article within 6 months of General Election 2015"

*--- By-elections ------------------------------------------------------
label var be2012       "=1 if article published in year of By-election 2012"
label var be2013       "=1 if article published in year of By-election 2013"
label var be2016       "=1 if article published in year of By-election 2016"

label var be2012_1mth  "=1 if article within 1 month of By-election 2012"
label var be2012_3mths "=1 if article within 3 months of By-election 2012"
label var be2013_1mth  "=1 if article within 1 month of By-election 2013"
label var be2013_3mths "=1 if article within 3 months of By-election 2013"
label var be2016_1mth  "=1 if article within 1 month of By-election 2016"
label var be2016_3mths "=1 if article within 3 months of By-election 2016"

*--- Presidential elections --------------------------------------------
label var pe2005       "=1 if article published in year of Presidential Election 2005"
label var pe2011       "=1 if article published in year of Presidential Election 2011"

label var pe2005_1mth  "=1 if article within 1 month of Presidential Election 2005"
label var pe2005_3mths "=1 if article within 3 months of Presidential Election 2005"
label var pe2005_6mths "=1 if article within 6 months of Presidential Election 2005"

label var pe2011_1mth  "=1 if article within 1 month of Presidential Election 2011"
label var pe2011_3mths "=1 if article within 3 months of Presidential Election 2011"
label var pe2011_6mths "=1 if article within 6 months of Presidential Election 2011"

*======================================================================
* ARTICLE-LEVEL VARIABLES: SECTION, AUTHOR, LANGUAGE, BEAT
*======================================================================
* Encoded section with 'others' as base
label define section2_label ///
    1 "home" 2 "insight" 3 "money" 4 "news" 5 "opinion" 6 "others" ///
    7 "prime news" 8 "review - insight" 9 "singapore" 10 "sports" ///
    11 "st" 12 "think" 13 "top of the news" 14 "world"
encode section2, gen(sect2) label(section2_label)
drop section2
rename sect2 section2
fvset base 6 section2
label var section2 "Section of article (base: others)"

* Language / translation flags
label var malay        "=1 if quote is in Malay"
label var mandarin     "=1 if quote is in Mandarin"
label var tamil        "=1 if quote is in Tamil"
label var vernacular   "=1 if quote is in a non-English vernacular language"
label var translations "=1 if quote translated from vernacular to English"

* Author and beat
rename author_cleaned2 authorID
label var authorID "Author ID"

encode beat, gen(beat2)
drop beat
rename beat2 beat
label var beat "Beat assignment of reporter"

*--- Weekday of publication -------------------------------------------
label define weekday_label ///
    1 "monday" 2 "tuesday" 3 "wednesday" 4 "thursday" 5 "friday" 6 "saturday" 7 "sunday"
encode weekday, gen(dayofweek) label(weekday_label)
drop weekday
rename dayofweek weekday
fvset base 1 weekday
label var weekday "Day of week of article publication"

*======================================================================
* TEXT LENGTH
*======================================================================
* Word counts
rename wordcount_quote      quote
label var quote             "Word count of quote"

rename wordcount_paragraph  paragraph
label var paragraph         "Word count of paragraph"

rename wordcount_fullspeech speech
label var speech            "Word count of full speech"

rename wordcount            article
label var article           "Article length (words)"

* Character counts
rename char_count_quote     quote_char
label var quote_char        "Character count of quote"

rename char_count_paragraph paragraph_char
label var paragraph_char    "Character count of paragraph"

rename char_count_fullspeech speech_char
label var speech_char       "Character count of speech"

rename article_len_char     article_char
label var article_char      "Article length (characters)"

* Log transformations
#delimit ;
global log_variables "
    quote 
    quote_char 
    paragraph 
    paragraph_char
    speech
    speech_char 
    article
    article_char
";
#delimit cr

foreach var in $log_variables {
    gen ln_`var' = ln(`var')
    label var ln_`var' "ln of `var'"
}

*======================================================================
* TOPIC DISTRIBUTIONS
*======================================================================

* 50-topic models: quote, speech, article
forvalues i = 1/50 {
    label var quote_50K_`i'   "Probability for topic `i'/50 for quote"
    label var speech_50K_`i'  "Probability for topic `i'/50 for speech"
    label var article_50K_`i' "Probability for topic `i'/50 for article"
}

* 92-topic models: quote, speech, sentence
forvalues i = 1/92 {
    label var quote_92K_`i'    "Probability for topic `i'/92 for quote"
    label var speech_92K_`i'   "Probability for topic `i'/92 for speech"
    label var sentence_92K_`i' "Probability for topic `i'/92 for sentence"
}

* 100-topic models: quote, speech
forvalues i = 1/100 {
    label var quote_100K_`i'  "Probability for topic `i'/100 for quote"
    label var speech_100K_`i' "Probability for topic `i'/100 for speech"
}

* Article-level topic models (30 and 40 topics)
forvalues i = 1/30 {
    label var article_30K_`i' "Probability for topic `i'/30 for article"
}

forvalues i = 1/40 {
    label var article_40K_`i' "Probability for topic `i'/40 for article"
}

*======================================================================
* LEXICAL RICHNESS
*======================================================================
label var ttr    "Type-token ratio"
label var rttr   "Root type-token ratio"
label var cttr   "Corrected type-token ratio"
label var herdan "Herdan's C lexical diversity"
label var summer "Summer lexical diversity index"
label var dugast "Dugast lexical diversity index"
label var maas   "Maas lexical diversity index"
label var msttr  "Mean segmental type-token ratio"
label var mattr  "Moving-average type-token ratio"
label var mtld   "Measure of textual lexical diversity"
label var hdd    "Hypergeometric distribution diversity"

*======================================================================
* READABILITY
*======================================================================
label var dalechall     "Dale-Chall readability index"
label var flesch        "Flesch reading easse score"
label var fleschkincaid "Flesch-Kincaid grade level"
label var gunningfog    "Gunning-Fog readability index"
label var smog          "SMOG readability index"
label var notdalechall  "Share of difficult words (not in Dale-Chall list)"
label var polysyllable  "Number of polysyllabic words (more than 3 syllables)"
label var syllables     "Total number of syllables"
label var sentences     "Total number of sentences"

*======================================================================
* SUBJECTIVITY, OBJECTIVITY, POLARITY
*======================================================================
* Subjectivity (0 = objective, 1 = subjective)
gen speech_objectivity         = 1 - speech_subjectivity
label var speech_subjectivity  "Speech subjectivity (0 objective - 1 subjective)"

gen para_objectivity           = 1 - para_subjectivity
label var para_subjectivity    "Paragraph subjectivity (0-1)"

gen sentence_objectivity       = 1 - sentence_subjectivity
label var sentence_subjectivity "Sentence subjectivity (0-1)"

gen quote_objectivity          = 1 - quote_subjectivity
label var quote_subjectivity   "Quote subjectivity (0-1)"

gen quote_sentence_objectivity = 1 - quote_sentence_subjectivity
label var quote_sentence_subjectivity "Quote sentence subjectivity (0-1)"

label var speech_objectivity         "Speech objectivity (0 objective - 1 subjective)"
label var para_objectivity           "Paragraph objectivity (0-1)"
label var sentence_objectivity       "Sentence objectivity (0-1)"
label var quote_objectivity          "Quote objectivity (0-1)"
label var quote_sentence_objectivity "Quote sentence objectivity (0-1)"

* Polarity (-1 = negative, +1 = positive)
label var speech_polarity         "Speech polarity (-1 negative to +1 positive), PatternAnalyzer"
label var para_polarity           "Paragraph polarity (-1 to +1), PatternAnalyzer"
label var sentence_polarity       "Sentence polarity (-1 to +1), PatternAnalyzer"
label var quote_polarity          "Quote polarity (-1 to +1), PatternAnalyzer"
label var quote_sentence_polarity "Quote sentence polarity (-1 to +1), PatternAnalyzer"
