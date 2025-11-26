# ---
# jupyter:
#   jupytext:
#     formats: ipynb,.//py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.17.2
#   kernelspec:
#     display_name: Python (venv_media)
#     language: python
#     name: venv_media
# ---

# %%
import pandas as pd
import numpy as np
import janitor

janitor
from collections import Counter
from tqdm.notebook import tqdm
from IPython.display import display
import re
import string
import datetime
import warnings
from nltk.corpus import stopwords

stopwords_cache = stopwords.words("english")

warnings.filterwarnings("ignore")

from utilities import (
    load_input_data,
    clean_quote_speech,
    clean_stopwords,
    clean_content,
)

FP_OG_ARTICLE_TEXT = "./input/all_articles_final.xlsx"
SAVEPATH = "intermediate/build-article.csv"

df = load_input_data()
display(df.head())
df.info()

# %% [markdown]
# ## Authors
# Handle author name typo errors. Also ensures that there are no duplicates.

# %%
for ix in range(len(df)):
    note = df.loc[ix, "add_notes"]
    if type(note) != float:
        if "author:" in note:
            df.loc[ix, "author"] = re.findall(":(.+)", note)[0]


# %%
def remove_punctuation(word):
    for p in list(string.punctuation):
        word = word.replace(p, "")
    return word


def clean_authors(entry):
    """Normalise and clean the entries in the 'author' column.
    Argument is in string format: the entry in a df cell.

    1. Removes 'By '
    2. convert to lowercaps
    3. remove all punctuations using built-in string.punctuation
    4. replaces all "and "'s with '& '
    5. replaces all whitespaces with a single whitespace
    6. clean spelling/name errors using dict_clean_authors

    Return: string
    """
    dict_clean_authors = {
        "politcal": "political",
        "k c vijayan": "kc vijayan",
        "kcvijayan": "kc vijayan",
        "sue annchia": "sueann chia",
        "janice tai priscilla goy": "janice tai & priscilla goy",
        "tessa wong rachel chang": "tessa wong & rachel chang",
        "stacy chia": "stacey chia",
        "jasmine yahya": "yasmine yahya",
        "nur asyiqin mohamad salleh": "asyiqin mohamad salleh",
        "aaron low rachel chang": "aaron low & rachel chang",
        "andrea ong lim yi han": "andrea ong & lim yi han",
        "ang yiying carolyn quek": "ang yiying & carolyn quek",
        "cai haoxiang teo wan gek": "cai haoxiang & teo wan gek",
        "calvin yangpearl lee": "calvin yang & pearl lee",
        "chang ailien meng yew choong": "chang ailien & meng yew choong",
        "charissa yongrachel auyong": "charissa yong & rachel auyong",
        "chia yan mineconomics correspondent": "chia yan min economics correspondent",
        "chia yan minwong wei han": "chia yan min & wong wei han",
        "daryl chin tessa wong": "daryl chin & tessa wong",
        "elgin toh chong zi liang": "elgin toh & chong zi liang",
        "faye chiam pui hoon ms": "faye chiam pui hoon",
        "janice heng cai haoxiang": "janice heng & cai haoxiang",
        "janice heng lim yi han": "janice heng & lim yi han",
        "janice hengcharissa yongaaron low": "janice heng & charissa yong & aaron low",
        "jennani durai janice tai": "jennani durai & janice tai",
        "leonard lim shuli sudderuddin": "leonard lim & shuli sudderuddin",
        "leonard lim teo wan gek": "leonard lim & teo wan gek",
        "leslie koh tania tan": "leslie koh & tania tan",
        "li xueying tracy sua": "li xueying & tracy sua",
        "lynn lee aaron low": "lynn lee & aaron low",
        "lynn lee li xueying": "lynn lee & li xueying",
        "ong hwee hweechew hui min": "ong hwee hwee & chew hui min",
        "phua mei pin toh yong chuan": "phua mei pin & toh yong chuan",
        "poon chian hui fiona low": "poon chian hui & fiona low",
        "rachel auyong lim yan liang walter sim": "rachel auyong & lim yan liang & walter sim",
        "rachel auyong linette lai": "rachel auyong & linette lai",
        "sueann chia zakir hussain": "sueann chia & zakir hussain",
        "tania tan jessica cheam": "tania tan & jessica cheam",
        "tee hun ching lim wei chean": "tee hun ching & lim wei chean",
        "teo wan gek jennani durai": "teo wan gek & jennani durai",
        "tessa wong teo wan gek": "tessa wong & teo wan gek",
        "tham yuenc bryna sim": "tham yuenc & bryna sim",
        "tham yuencwong siew ying": "tham yuenc & wong siew ying",
        "yasmine yahyaassistant business editor": "yasmine yahya assistant business editor",
        "yasmine yahya goh chin lian": "yasmine yahya & goh chin lian",
        "yeo sam jo rachel auyong": "yeo sam jo & rachel auyong",
        "yeo sam jo & rachel auyong": "rachel auyong & yeo sam jo",
    }

    if type(entry) != float:
        entry = entry.replace("By ", " ")
        entry = entry.lower()
        entry = remove_punctuation(entry)
        entry = entry.replace("and ", "& ")

        entry = re.sub("\s+", " ", entry).strip()

        for key in dict_clean_authors:
            entry = entry.replace(key, dict_clean_authors[key])

        entry = re.sub("\s+", " ", entry).strip()
    return entry


df["author_cleaned"] = df["author"].apply(clean_authors)

# %%
authors = Counter(df.author_cleaned.tolist())

authors_df = pd.DataFrame.from_dict(Counter(df.author_cleaned.tolist()), orient="index")
authors_df.columns = ["count"]
authors_df.sort_values("count", ascending=False)


# %% [markdown]
# ### Beat

# %%
def get_beat(author_cleaned):
    beats = [
        "political",
        "defence",
        "health",
        "transport",
        "technology",
        "manpower",
        "law",
        "housing",
        "education",
        "aviation",
        "money",
        "environment",
        "companies",
        "economics",
        "arts",
        "consumer",
        "property",
        "business",
        "sports",
    ]
    # return nan if author_cleaned is nan
    if type(author_cleaned) == float:
        return np.nan

    for beat in beats:
        if beat in author_cleaned:
            return beat
    return "none"


df["beat"] = df["author_cleaned"].apply(get_beat)

# %%
df.head()


# %%
def clean_authors2(author_cleaned):
    """Remove non-name words in author string using the remove_nonname_words list."""
    remove_nonname_words = [
        "correspondent",
        "for",
        "the",
        "sunday",
        "times",
        "straits",
        "opinion",
        "editor",
        "political",
        "manpower",
        "consumer",
        "deputy",
        "senior",
        "assistant",
        "defence",
        "health",
        "associate",
        "transport",
        "technology",
        "law",
        "writer",
        "news",
        "news",
        "housing",
        "education",
        "aviation",
        "money",
        "environment",
        "companies",
        "from",
        "gallery",
        "economics",
        "bureau",
        "chief",
        "arts",
        "supervising",
        "home",
        "property",
        "reporter",
        "business",
        "us",
        "sports",
        "managing",
        "contributing",
        "indonesia",
    ]

    # return nan if author_cleaned is nan
    if type(author_cleaned) == float:
        return np.nan

    author_cleaned2 = [
        word for word in author_cleaned.split(" ") if word not in remove_nonname_words
    ]
    author_cleaned2 = " ".join(author_cleaned2)

    # clean whitespaces
    author_cleaned2 = re.sub(r"\s+", " ", author_cleaned2).strip()

    return author_cleaned2


df["author_cleaned2"] = df["author_cleaned"].apply(clean_authors2)

# %%
authors = Counter(df.author_cleaned2.tolist())

authors_df = pd.DataFrame.from_dict(
    Counter(df.author_cleaned2.tolist()), orient="index"
)
authors_df.columns = ["count"]
authors_df.sort_values("count", ascending=False)

# %%
df["author_cleaned2"] = (
    df.groupby(["title", "date"])["author_cleaned2"]
    .apply(lambda x: x.bfill().ffill())
    .droplevel([0, 1])  # Remove the MultiIndex levels
)

# %% [markdown]
# ## Article level variables
# * wordcount
# * content
# * character length
# * wordcount nostopwords
# * character len no stopwords

# %% [markdown]
# ### Length

# %%
df_og_article_text = (
    pd.read_excel(FP_OG_ARTICLE_TEXT, usecols=["title", "date", "content", "wordcount"])
    .assign(title=lambda df_: df_["title"].str.lower())
    # convert wordcount column to integer (e.g. "602 words" to 602)
    .assign(
        wordcount=lambda df_: df_["wordcount"].apply(
            lambda x: int(x.replace("words", "").strip())
        )
    )
    .assign(content_cleaned=lambda df_: df_["content"].apply(clean_content))
    # Get character length of content
    .assign(
        article_len_char=lambda df_: df_["content_cleaned"].apply(len),
        # Remove stopwords from content
        content_cleaned_nostopwords=lambda df_: df_["content_cleaned"].apply(
            lambda x: (
                " ".join([word for word in x.split() if word not in stopwords_cache])
                if pd.notna(x)
                else x
            )
        ),
    )
    # Clean up extra whitespace in stopword-removed content
    .assign(
        content_cleaned_nostopwords=lambda df_: df_[
            "content_cleaned_nostopwords"
        ].apply(lambda x: re.sub("\s+", " ", x).strip() if pd.notna(x) else x),
    )
    # Get length w/o stopwords
    .assign(
        _article=lambda df_: df_["content_cleaned_nostopwords"].apply(
            lambda x: len(x.split(" ")) if pd.notna(x) else 0
        ),  # Word count
        _article_len_char=lambda df_: df_["content_cleaned_nostopwords"].str.len(),
    )
    .remove_columns(["content", "content_cleaned", "content_cleaned_nostopwords"])
)

print("length of raw dataframe is {}".format(len(df_og_article_text)))
display(df_og_article_text.head())
df_og_article_text.info()

# %%
df = df.merge(df_og_article_text, how="inner", on=["title", "date"])
df.head(3)

# %% [markdown]
# ### Section

# %%
df["section"] = df["section"].apply(lambda x: x.lower())

# %%
df[df["section"].str.contains("growth strategy")]

# %%
qids = [9514, 9515, 9516, 9517, 9518, 9519]
df.loc[df["qid"].isin(qids), "author_cleaned"] = "fiona chan"
df.loc[df["qid"].isin(qids), "title"] = "growth strategy 'not wrong-headed'"
df.loc[df["qid"].isin(qids), "section"] = "singapore"

# %%
sections = pd.DataFrame.from_dict(dict(Counter(df["section"].tolist())), orient="index")
sections.columns = ["count"]

sections.sort_values("count", ascending=False)

# %%
dict_sections = {
    "thin": "think",
    "st forum - online story": "others",
    "life!": "others",
    "saturday special report": "others",
    "asia - south-east asia": "others",
    "forum letters": "others",
    "review": "others",
    "business": "others",
    "st forum": "others",
    "review - others": "others",
    "singapore": "singapore",
    "prime news": "prime news",
    "top of the news": "top of the news",
    "home": "home",
    "st": "st",
    "insight": "insight",
    "news": "news",
    "money": "money",
    "think": "think",
    "sports": "sports",
    "review - insight": "review - insight",
    "opinion": "opinion",
    "world": "world",
}

# %%
df["section2"] = df["section"].map(dict_sections)

# %%
# convert nan to others
df["section2"] = np.where(df["section2"].isnull(), "others", df["section2"])

# %%
sections = pd.DataFrame.from_dict(
    dict(Counter(df["section2"].tolist())), orient="index"
)
sections.columns = ["count"]

sections.sort_values("count", ascending=False)

# %% [markdown]
# ### Word count

# %%
df["quote_cleaned"] = df["quote"].apply(clean_quote_speech)
df["matched_paragraph_cleaned"] = df["matched_paragraph"].apply(clean_quote_speech)
df["matched_sentence_cleaned"] = df["matched_sentence"].apply(clean_quote_speech)
df["matched_fullspeech_cleaned"] = df["matched_fullspeech"].apply(clean_quote_speech)

# %%
cols = [
    "quote_cleaned",
    "matched_sentence_cleaned",
    "matched_paragraph_cleaned",
    "matched_fullspeech_cleaned",
]
for col in tqdm(cols):
    df[f"{col}_nostopwords"] = df[col].apply(
        lambda x: clean_stopwords(x, stopwords_cache)
    )

# %%
# wordcount
df["wordcount_quote"] = df["quote_cleaned"].apply(
    lambda x: len(x.split(" ")) if pd.notna(x) else np.nan
)
df["wordcount_paragraph"] = df["matched_paragraph_cleaned"].apply(
    lambda x: len(x.split(" ")) if pd.notna(x) else np.nan
)
df["wordcount_fullspeech"] = df["matched_fullspeech_cleaned"].apply(
    lambda x: len(x.split(" ")) if pd.notna(x) else np.nan
)

# character count
df["char_count_quote"] = df["quote_cleaned"].str.len()
df["char_count_paragraph"] = df["matched_paragraph_cleaned"].str.len()
df["char_count_fullspeech"] = df["matched_fullspeech_cleaned"].str.len()

# wordcount without stopwords
df["wordcount_nostopwords_quote"] = df["quote_cleaned_nostopwords"].apply(
    lambda x: len(x.split(" ")) if pd.notna(x) else np.nan
)
df["wordcount_nostopwords_paragraph"] = df[
    "matched_paragraph_cleaned_nostopwords"
].apply(lambda x: len(x.split(" ")) if pd.notna(x) else np.nan)
df["wordcount_nostopwords_fullspeech"] = df[
    "matched_fullspeech_cleaned_nostopwords"
].apply(lambda x: len(x.split(" ")) if pd.notna(x) else np.nan)

# character  without stopwords
df["char_count_nostopwords_quote"] = df["quote_cleaned_nostopwords"].str.len()
df["char_count_nostopwords_paragraph"] = df[
    "matched_paragraph_cleaned_nostopwords"
].str.len()
df["char_count_nostopwords_fullspeech"] = df[
    "matched_fullspeech_cleaned_nostopwords"
].str.len()


# %% [markdown]
# ## Flagging out translations
# Using the simple hueristic:
# 1. look for strings in parentheses and brackets
# 2. check for:
#     * 'in malay'
#     * 'in mandarin'
#     * 'in tamil'
# aaaaaaaaaaaaaaaa    * 'vernacular'

# %%
def find_strings_brackets_parentheses(text):
    """Extracts strings in parentheses and brackets, then return individual words as a list.
    Argument is a string.
    1.) Extracts all strings into parentheses and brackets.
    2.) Join all substrings into a single string.
    """
    results = re.findall("\((.+?)\)", text.lower())
    results += re.findall("\[(.+?)\]", text)

    return " ".join(results)


def check_malay(text):
    if "in malay" in find_strings_brackets_parentheses(text):
        return 1
    else:
        return 0


def check_mandarin(text):
    if "in mandarin" in find_strings_brackets_parentheses(text):
        return 1
    else:
        return 0


def check_tamil(text):
    if "in tamil" in find_strings_brackets_parentheses(text):
        return 1
    else:
        return 0


def check_vernacular(text):
    if "vernacular" in find_strings_brackets_parentheses(text):
        return 1
    else:
        return 0


df["malay"] = df["matched_fullspeech"].apply(check_malay)
df["mandarin"] = df["matched_fullspeech"].apply(check_mandarin)
df["tamil"] = df["matched_fullspeech"].apply(check_tamil)
df["vernacular"] = df["matched_fullspeech"].apply(check_vernacular)
df["translations"] = df["malay"] + df["mandarin"] + df["tamil"]

# %% [markdown]
# ## Creating year/time variables
# * year dummies
# * parliament life dummies (10 to 13)
# * GE year dummies (2006, 2011, 2015)
# * 1 month before GE
# * 3 months before GE
# * 6 months before GE
# * Presidential elections (2005, 2011)
# * 1 months before PE
# * 3 months before PE
# * 6 months before PE
# * BE year dummies (2012, 2013, 2016)
# * 1 months before BE
# * 3 months before BE
# * 6 months before BE
# * Weekday dummies
# * __if polling day happens after the 15th, the current month is counted as a month, otherwise the current month is not counted as a month (e.g. if polling day is on 6 may 2011, then 1 month before starts from 1 apr 2011; if polling day is on 26 jan 2013, then 1 month before starts on 1 jan 2013.)__

# %%
df["year"] = df["date"].apply(lambda date: date.year)

# %% [markdown]
# ### parliament life dummies
# * 10th parliament 25 mar 2002 to 4 apr 2006
# * 11th parliament 2 nov 2006 to 19 apr 2011
# * 12th parliament 10 oct 2011 to 25 aug 2015
# * 13th parliament 15 jan 2016 to ---

# %%
# df["matched_date"] = np.where(
#     df["matched_date"].isnull(), df["date"], df["matched_date"]
# )

# df["parl10"] = np.where(df["matched_date"] <= datetime.datetime(2006, 4, 20), 1, 0)
# df["parl11"] = np.where(
#     (df["matched_date"] >= datetime.datetime(2006, 11, 2))
#     & (df["matched_date"] <= datetime.datetime(2011, 4, 19)),
#     1,
#     0,
# )
# df["parl12"] = np.where(
#     (df["matched_date"] >= datetime.datetime(2011, 10, 10))
#     & (df["matched_date"] <= datetime.datetime(2015, 8, 25)),
#     1,
#     0,
# )
# df["parl13"] = np.where(df["matched_date"] >= datetime.datetime(2016, 1, 15), 1, 0)

# df["parl"] = ""
# df["parl"] = np.where(
#     df["matched_date"] <= datetime.datetime(2006, 4, 20), "10th parliament", df["parl"]
# )
# df["parl"] = np.where(
#     (df["matched_date"] >= datetime.datetime(2006, 11, 2))
#     & (df["matched_date"] <= datetime.datetime(2011, 4, 19)),
#     "11th parliament",
#     df["parl"],
# )
# df["parl"] = np.where(
#     (df["matched_date"] >= datetime.datetime(2011, 10, 10))
#     & (df["matched_date"] <= datetime.datetime(2015, 8, 25)),
#     "12th parliament",
#     df["parl"],
# )
# df["parl"] = np.where(
#     df["matched_date"] >= datetime.datetime(2016, 1, 15), "13th parliament", df["parl"]
# )

# %% [markdown]
# ### general election years
# * 2006 (polling day: 6 may 2006)
# * 2011 (polling day: 7 may 2011)
# * 2015 (polling day: 11 sep 2015)

# %%
ge2006_start = datetime.datetime(2006, 1, 1)
ge2006_end = datetime.datetime(2006, 12, 31)

ge2011_start = datetime.datetime(2011, 1, 1)
ge2011_end = datetime.datetime(2011, 12, 31)

ge2015_start = datetime.datetime(2015, 1, 1)
ge2015_end = datetime.datetime(2015, 12, 31)

ge2006_1mths_before = datetime.datetime(2006, 4, 1)
ge2006_3mths_before = datetime.datetime(2006, 3, 1)
ge2006_6mths_before = datetime.datetime(2005, 12, 1)
ge2006_pollingday = datetime.datetime(2006, 5, 6)

ge2011_1mths_before = datetime.datetime(2011, 4, 1)
ge2011_3mths_before = datetime.datetime(2011, 3, 1)
ge2011_6mths_before = datetime.datetime(2010, 12, 1)
ge2011_pollingday = datetime.datetime(2011, 5, 7)

ge2015_1mths_before = datetime.datetime(2015, 8, 1)
ge2015_3mths_before = datetime.datetime(2015, 7, 1)
ge2015_6mths_before = datetime.datetime(2015, 4, 1)
ge2015_pollingday = datetime.datetime(2015, 9, 11)

# %%
df["ge2006"] = np.where((df["date"] >= ge2006_start) & (df["date"] <= ge2006_end), 1, 0)
df["ge2011"] = np.where((df["date"] >= ge2011_start) & (df["date"] <= ge2011_end), 1, 0)
df["ge2015"] = np.where((df["date"] >= ge2015_start) & (df["date"] <= ge2015_end), 1, 0)

# %%
# 1 mth, 3 mths and 6 mths before GE
df["ge2006_1mth"] = np.where(
    (df["date"] >= ge2006_1mths_before) & (df["date"] <= ge2006_pollingday), 1, 0
)
df["ge2006_3mths"] = np.where(
    (df["date"] >= ge2006_3mths_before) & (df["date"] <= ge2006_pollingday), 1, 0
)
df["ge2006_6mths"] = np.where(
    (df["date"] >= ge2006_6mths_before) & (df["date"] <= ge2006_pollingday), 1, 0
)

df["ge2011_1mth"] = np.where(
    (df["date"] >= ge2011_1mths_before) & (df["date"] <= ge2011_pollingday), 1, 0
)
df["ge2011_3mths"] = np.where(
    (df["date"] >= ge2011_3mths_before) & (df["date"] <= ge2011_pollingday), 1, 0
)
df["ge2011_6mths"] = np.where(
    (df["date"] >= ge2011_6mths_before) & (df["date"] <= ge2011_pollingday), 1, 0
)

df["ge2015_1mth"] = np.where(
    (df["date"] >= ge2015_1mths_before) & (df["date"] <= ge2015_pollingday), 1, 0
)
df["ge2015_3mths"] = np.where(
    (df["date"] >= ge2015_3mths_before) & (df["date"] <= ge2015_pollingday), 1, 0
)
df["ge2015_6mths"] = np.where(
    (df["date"] >= ge2015_6mths_before) & (df["date"] <= ge2015_pollingday), 1, 0
)

# %% [markdown]
# ### By-election years
# * 2012 (polling day: 26 may 2012)
# * 2013 (polling day: 26 jan 2013)
# * 2016 (polling day: 7 may 2016)

# %%
be2012_start = datetime.datetime(2012, 1, 1)
be2012_end = datetime.datetime(2012, 12, 31)

be2013_start = datetime.datetime(2013, 1, 1)
be2013_end = datetime.datetime(2013, 12, 31)

be2016_start = datetime.datetime(2016, 1, 1)
be2016_end = datetime.datetime(2016, 12, 31)

be2012_1mth_before = datetime.datetime(2012, 5, 1)
be2012_3mths_before = datetime.datetime(2012, 3, 1)
be2012_pollingday = datetime.datetime(2012, 5, 26)

be2013_1mth_before = datetime.datetime(2013, 1, 1)
be2013_3mths_before = datetime.datetime(2012, 11, 1)
be2013_pollingday = datetime.datetime(2013, 1, 26)

be2016_1mth_before = datetime.datetime(2016, 4, 1)
be2016_3mths_before = datetime.datetime(2016, 2, 1)
be2016_pollingday = datetime.datetime(2016, 5, 7)

# %%
df["be2012"] = np.where((df["date"] >= be2012_start) & (df["date"] <= be2012_end), 1, 0)
df["be2013"] = np.where((df["date"] >= be2013_start) & (df["date"] <= be2013_end), 1, 0)
df["be2016"] = np.where((df["date"] >= be2016_start) & (df["date"] <= be2016_end), 1, 0)

# %%
#  1mth and 3mths before BE
df["be2012_1mth"] = np.where(
    (df["date"] >= be2012_1mth_before) & (df["date"] <= be2012_pollingday), 1, 0
)
df["be2012_3mths"] = np.where(
    (df["date"] >= be2012_3mths_before) & (df["date"] <= be2012_pollingday), 1, 0
)

df["be2013_1mth"] = np.where(
    (df["date"] >= be2013_1mth_before) & (df["date"] <= be2013_pollingday), 1, 0
)
df["be2013_3mths"] = np.where(
    (df["date"] >= be2013_3mths_before) & (df["date"] <= be2013_pollingday), 1, 0
)

df["be2016_1mth"] = np.where(
    (df["date"] >= be2016_1mth_before) & (df["date"] <= be2016_pollingday), 1, 0
)
df["be2016_3mths"] = np.where(
    (df["date"] >= be2016_3mths_before) & (df["date"] <= be2016_pollingday), 1, 0
)

# %% [markdown]
# ### Presidential election years
# * 2005 (nomination day 17 aug 2005)
# * 2011 (polling day 27 aug 2011)

# %%
pe2005_start = datetime.datetime(2005, 1, 1)
pe2005_end = datetime.datetime(2005, 12, 31)

pe2011_start = datetime.datetime(2011, 1, 1)
pe2011_end = datetime.datetime(2011, 12, 31)

pe2005_1mth_before = datetime.datetime(2005, 8, 1)
pe2005_3mths_before = datetime.datetime(2005, 6, 1)
pe2005_6mths_before = datetime.datetime(2005, 3, 1)
pe2005_nominationday = datetime.datetime(2005, 8, 17)

pe2011_1mth_before = datetime.datetime(2011, 8, 1)
pe2011_3mths_before = datetime.datetime(2011, 6, 1)
pe2011_6mths_before = datetime.datetime(2011, 3, 1)
pe2011_pollingday = datetime.datetime(2011, 8, 27)

# %%
df["pe2005"] = np.where((df["date"] >= pe2005_start) & (df["date"] <= pe2005_end), 1, 0)
df["pe2011"] = np.where((df["date"] >= pe2011_start) & (df["date"] <= pe2011_end), 1, 0)

# %%
# 1mth, 3mths, and 6mths before PE
df["pe2005_1mth"] = np.where(
    (df["date"] >= pe2005_1mth_before) & (df["date"] <= pe2005_nominationday), 1, 0
)
df["pe2005_3mths"] = np.where(
    (df["date"] >= pe2005_3mths_before) & (df["date"] <= pe2005_nominationday), 1, 0
)
df["pe2005_6mths"] = np.where(
    (df["date"] >= pe2005_6mths_before) & (df["date"] <= pe2005_nominationday), 1, 0
)

df["pe2011_1mth"] = np.where(
    (df["date"] >= pe2011_1mth_before) & (df["date"] <= pe2011_pollingday), 1, 0
)
df["pe2011_3mths"] = np.where(
    (df["date"] >= pe2011_3mths_before) & (df["date"] <= pe2011_pollingday), 1, 0
)
df["pe2011_6mths"] = np.where(
    (df["date"] >= pe2011_6mths_before) & (df["date"] <= pe2011_pollingday), 1, 0
)


# %% [markdown]
# ### DoW dummies

# %%
def get_weekday(date):
    """Date is a pandas._libs.tslib.Timestamp object."""

    weekdays_dict = {
        0: "monday",
        1: "tuesday",
        2: "wednesday",
        3: "thursday",
        4: "friday",
        5: "saturday",
        6: "sunday",
    }

    weekday_int = date.weekday()
    weekday = weekdays_dict[weekday_int]

    return weekday


df["weekday"] = df["date"].apply(get_weekday)

# %%
(
    df.assign(
        article_id=lambda df_: df_.groupby(["title", "date"]).ngroup(),
        speech_id=lambda df_: pd.factorize(df_["matched_fullspeech"])[0],
        author_cleaned2=lambda df_: 1 + pd.factorize(df_["author_cleaned2"])[0],
    )
    .filter(
        [
            "qid",
            "article_id",
            "speech_id",
            "beat",
            "author_cleaned2",
            "wordcount",
            "article_len_char",
            "_article",
            "_article_len_char",
            "section2",
            "wordcount_quote",
            "wordcount_paragraph",
            "wordcount_fullspeech",
            "char_count_quote",
            "char_count_paragraph",
            "char_count_fullspeech",
            "wordcount_nostopwords_quote",
            "wordcount_nostopwords_paragraph",
            "wordcount_nostopwords_fullspeech",
            "char_count_nostopwords_quote",
            "char_count_nostopwords_paragraph",
            "char_count_nostopwords_fullspeech",
            "malay",
            "mandarin",
            "tamil",
            "vernacular",
            "translations",
            "year",
            "ge2006",
            "ge2011",
            "ge2015",
            "ge2006_1mth",
            "ge2006_3mths",
            "ge2006_6mths",
            "ge2011_1mth",
            "ge2011_3mths",
            "ge2011_6mths",
            "ge2015_1mth",
            "ge2015_3mths",
            "ge2015_6mths",
            "be2012",
            "be2013",
            "be2016",
            "be2012_1mth",
            "be2012_3mths",
            "be2013_1mth",
            "be2013_3mths",
            "be2016_1mth",
            "be2016_3mths",
            "pe2005",
            "pe2011",
            "pe2005_1mth",
            "pe2005_3mths",
            "pe2005_6mths",
            "pe2011_1mth",
            "pe2011_3mths",
            "pe2011_6mths",
            "weekday",
        ]
    )
    .to_csv(SAVEPATH, index=False)
)

# %%
