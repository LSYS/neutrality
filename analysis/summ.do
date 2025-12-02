cap log close
local log ./logs/summ
log using `log'.smcl, replace smcl

qui do init.do

qui reg ss1_quote_to_speech i.opposition $length_s $base_controls $min, 
keep if e(sample)

*======================================================================
* Unique MPs (mp): 204
*   - Opposition MPs:      16
*   - Non-partisan MPs:    44
*   - Ruling-party MPs:   144
count_unique mp
count_unique mp if opposition
count_unique mp if non_partisan
count_unique mp if ruling

*======================================================================
* Total quotes: 14,901
*   - Opposition MPs:     1,105 quotes
*   - Non-partisan MPs:     475 quotes
*   - Ruling-party MPs:   13,321 quotes
count
count if opposition
count if non_partisan
count if ruling

*======================================================================
* Unique articles (article_id): 3,421
*   - Articles with opposition quotes:      456
*   - Articles with non-partisan quotes:    261
*   - Articles with ruling-party quotes:   3,354
count_unique article_id
count_unique article_id if opposition
count_unique article_id if non_partisan
count_unique article_id if ruling

*======================================================================
* Quote length (words, variable: quote)
*   - All quotes:          mean 20.9,  sd 38.5
*   - Opposition quotes:   mean 20.1,  sd 18.2
*   - Non-partisan quotes: mean 23.7,  sd 19.3
*   - Ruling-party quotes: mean 20.9,  sd 40.2
su quote
su quote if opposition
su quote if non_partisan
su quote if ruling

*======================================================================
* Article length (words)
*   - All articles:          mean 625.4,  sd 263.4
*   - Opposition articles:   mean 696.9,  sd 339.7
*   - Non-partisan articles: mean 670.2,  sd 272.0
*   - Ruling-party articles: mean 617.9,  sd 254.7
su article
su article if opposition
su article if non_partisan
su article if ruling


*======================================================================
* Article length (words)
*   - All speeches:        mean 2,095.9,  sd 1,808.8
*   - Opposition speeches: mean 1,156.0,  sd   901.0
*   - Non-partisan:        mean 1,808.6,  sd 1,177.3
*   - Ruling-party:        mean 2,184.2,  sd 1,859.9
su speech 
su speech if opposition
su speech if non_partisan
su speech if ruling

*======================================================================
* Speech length (words)
*   - All speeches:        mean 2,095.9,  sd 1,808.8
*   - Opposition:          mean 1,156.0,  sd   901.0
*   - Non-partisan:        mean 1,808.6,  sd 1,177.3
*   - Ruling party:        mean 2,184.2,  sd 1,859.9
su speech
su speech if opposition
su speech if non_partisan
su speech if ruling

*======================================================================
* QUotes per article
*======================================================================
*   - All articles:         mean 4.36, sd 3.11
*   - Opposition articles:  mean 6.34, sd 3.71
*   - Non-partisan articles:mean 4.84, sd 3.15
*   - Ruling-party articles:mean 4.22, sd 3.02
bysort article_id: gen quotes_per_article = _N
egen art_tag = tag(article_id)

su quotes_per_article if art_tag
su quotes_per_article if art_tag & opposition
su quotes_per_article if art_tag & non_partisan
su quotes_per_article if art_tag & ruling

drop quotes_per_article art_tag

*======================================================================
* QUotes per MP
*======================================================================
*   - All MPs:            mean 73.0, sd 130.8
*   - Opposition MPs:     mean 69.1, sd 92.1
*   - Non-partisan MPs:   mean 10.8, sd 9.1
*   - Ruling-party MPs:   mean 92.5, sd 147.6
bysort mp: gen quotes_per_mp = _N
egen mp_tag = tag(mp)

su quotes_per_mp if mp_tag
su quotes_per_mp if mp_tag & opposition
su quotes_per_mp if mp_tag & non_partisan
su quotes_per_mp if mp_tag & ruling

drop quotes_per_mp mp_tag

*======================================================================
* QUotes per Speech
*======================================================================
*   - All speeches:        mean 2.91, sd 3.86
*   - Opposition speeches: mean 2.41, sd 2.40
*   - Non-partisan:        mean 1.97, sd 1.51
*   - Ruling speeches:     mean 3.01, sd 4.06
bysort speech_id: gen quotes_per_speech = _N
egen sp_tag = tag(speech_id)

su quotes_per_speech if sp_tag
su quotes_per_speech if sp_tag & opposition
su quotes_per_speech if sp_tag & non_partisan
su quotes_per_speech if sp_tag & ruling

drop quotes_per_speech sp_tag

*======================================================================
* QUotes per year
*======================================================================
*   - All quotes:        mean 1241.8, sd 402.3
*   - Opposition:        mean 92.1,   sd 50.6
*   - Non-partisan:      mean 39.6,   sd 14.7
*   - Ruling party:      mean 1110.1, sd 349.6
bysort year: gen quotes_per_year = _N
egen yr_tag = tag(year)

bysort year opposition: gen qpy_oppo = _N if opposition
bysort year non_partisan: gen qpy_nonp = _N if non_partisan
bysort year ruling: gen qpy_ruling = _N if ruling

egen yr_tag_oppo = tag(year) if opposition
egen yr_tag_nonp = tag(year) if non_partisan
egen yr_tag_ruling = tag(year) if ruling

su quotes_per_year if yr_tag
su qpy_oppo if yr_tag_oppo
su qpy_nonp if yr_tag_nonp
su qpy_ruling if yr_tag_ruling


*======================================================================
* QUotes per parl
*======================================================================
*   - All MPs:         mean 3,725.3, sd 2,205.8
*   - Opposition:      mean   276.3, sd   237.6
*   - Non-partisan:    mean   118.8, sd    67.9
*   - Ruling:          mean 3,330.3, sd 1,944.4
bysort parl: gen quotes_per_parl = _N
egen parl_tag = tag(parl)

* Opposition quotes per parliament
bysort parl: egen qpp_oppo   = total(opposition)
egen parl_tag_oppo = tag(parl) if !missing(qpp_oppo)

* Non-partisan quotes per parliament
bysort parl: egen qpp_nonp   = total(non_partisan)
egen parl_tag_nonp = tag(parl) if !missing(qpp_nonp)

* Ruling quotes per parliament
bysort parl: egen qpp_ruling = total(ruling)
egen parl_tag_ruling = tag(parl) if !missing(qpp_ruling)

* Summaries
su quotes_per_parl if parl_tag
su qpp_oppo       if parl_tag_oppo
su qpp_nonp       if parl_tag_nonp
su qpp_ruling     if parl_tag_ruling

*======================================================================
* Acc.
*======================================================================
*   - All quotes:      mean 91.5, sd 12.8
*   - Opposition:      mean 90.9, sd 12.7
*   - Non-partisan:    mean 91.7, sd 11.5
*   - Ruling:          mean 91.6, sd 12.9
su ss1_quote_to_speech
su ss1_quote_to_speech if opposition
su ss1_quote_to_speech if non_partisan
su ss1_quote_to_speech if ruling

*   - All quotes:      mean 96.7, sd 10.2
*   - Opposition:      mean 95.3, sd 13.2
*   - Non-partisan:    mean 97.5, sd 7.3
*   - Ruling:          mean 96.7, sd 10.0
su ss2_quote_to_speech
su ss2_quote_to_speech if opposition
su ss2_quote_to_speech if non_partisan
su ss2_quote_to_speech if ruling

*   - All quotes:      mean 89.9, sd 26.8
*   - Opposition:      mean 89.3, sd 26.7
*   - Non-partisan:    mean 93.8, sd 20.1
*   - Ruling:          mean 89.8, sd 27.1
su ce_max_quote2speech
su ce_max_quote2speech if opposition
su ce_max_quote2speech if non_partisan
su ce_max_quote2speech if ruling


*======================================================================
* 'Perfect' quotes
*======================================================================
* Perfect match indicators (1 = perfect, 0 = not perfect)
gen ss1_perfect = ss1_quote_to_speech == 100 if !missing(ss1_quote_to_speech)
label var ss1_perfect "Substring-1: perfect (=100)"

gen ss2_perfect = ss2_quote_to_speech == 100 if !missing(ss2_quote_to_speech)
label var ss2_perfect "Substring-2: perfect (=100)"

* For CE, this will probably all be 0 because max < 100, but for completeness:
gen ce_perfect  = ce_max_quote2speech >= 99 if !missing(ce_max_quote2speech)
label var ce_perfect "CE max: perfect (=100)"

* Substring
*   - All quotes:        42.2%
*   - Opposition:        38.8%
*   - Non-partisan:      35.8%
*   - Ruling:            42.7%
su ss1_perfect
su ss1_perfect if opposition
su ss1_perfect if non_partisan
su ss1_perfect if ruling

* Bow
*   - All quotes:        70.6%
*   - Opposition:        63.0%
*   - Non-partisan:      70.1%
*   - Ruling:            71.3%
su ss2_perfect
su ss2_perfect if opposition
su ss2_perfect if non_partisan
su ss2_perfect if ruling

* Semantic
*   - All quotes:        77.0%
*   - Opposition:        74.0%
*   - Non-partisan:      78.1%
*   - Ruling:            77.2%
su ce_perfect
su ce_perfect if opposition
su ce_perfect if non_partisan
su ce_perfect if ruling

*======================================================================
* Age 
*======================================================================

* Per-MP age (in case age is stored at quote level)
bysort mp: egen age_mp = mean(age)

* Tag unique MPs
egen mp_tag = tag(mp)

* Overall and by party
su age_mp if mp_tag
su age_mp if mp_tag & opposition
su age_mp if mp_tag & non_partisan
su age_mp if mp_tag & ruling

*======================================================================
* Tenure
*======================================================================

* Per-MP tenure (if stored at quote level)
bysort mp: egen tenure_mp = mean(tenure)

su tenure_mp if mp_tag
su tenure_mp if mp_tag & opposition
su tenure_mp if mp_tag & non_partisan
su tenure_mp if mp_tag & ruling

*======================================================================
* Gender of MPs (share female)
*======================================================================
bysort mp (gender): gen gender_mp = gender if _n == 1

*   - All MPs:          47 / 204 (23.0% female)
*   - Opposition MPs:    3 / 16  (18.8% female)
*   - Non-partisan MPs: 18 / 44  (40.9% female)
*   - Ruling-party MPs: 26 / 144 (18.1% female)
tab gender_mp if mp_tag
tab gender_mp if mp_tag & opposition
tab gender_mp if mp_tag & non_partisan
tab gender_mp if mp_tag & ruling

*======================================================================
* Gender of qutes
*======================================================================
*   - All quotes:        83.5% male, 16.5% female
*   - Opposition:        72.0% male, 28.0% female
*   - Non-partisan:      59.6% male, 40.4% female
*   - Ruling-party:      85.3% male, 14.7% female
tab gender
tab gender if opposition
tab gender if non_partisan
tab gender if ruling


su ss1_quote_to_speech ss2_quote_to_speech ce_max_quote2speech


log close
translate `log'.smcl `log'.log, replace linesize(150)
translate `log'.smcl `log'.pdf, replace
