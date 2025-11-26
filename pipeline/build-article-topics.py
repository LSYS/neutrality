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
import os
import pandas as pd
import janitor

janitor
from IPython.display import display
import warnings
from nltk.corpus import stopwords

stopwords_cache = stopwords.words("english")

warnings.filterwarnings("ignore")

from utilities import (
    load_input_data,
    clean_content,
    get_topics,
    return_token,
    upgrade_legacy_phraser,
)

FP_OG_ARTICLE_TEXT = "./input/all_articles_final.xlsx"
SAVEPATH = "intermediate/build-article-topics.csv"

from sys import stdout
import spacy

nlp = spacy.load("en_core_web_sm")

from gensim.models.ldamodel import LdaModel
from gensim.models.phrases import Phraser
from gensim.corpora import Dictionary

df = load_input_data()

display(df.head())
df.info(verbose=True)

# %%
# # !python -m spacy download en_core_web_sm

# %% [markdown]
# ### Load article content

# %%
df_og_article_text = (
    pd.read_excel(FP_OG_ARTICLE_TEXT, usecols=["title", "date", "content", "wordcount"])
    .assign(title=lambda df_: df_["title"].str.lower())
    # Get unique articles
    .merge(df.drop_duplicates(["title", "date"]), how="right", on=["title", "date"])
    .assign(content_cleaned=lambda df_: df_["content"].apply(clean_content))
    .remove_columns(["wordcount", "content"])
)

print("length of raw dataframe is {}".format(len(df_og_article_text)))
display(df_og_article_text.head())
df_og_article_text.info()

# %% [markdown]
# ### Load models

# %%
base = "./topic/saves/st"
bigram_in = os.path.join(base, "bigram-phraser-st")
trigram_in = os.path.join(base, "trigram-phraser-st")

bigram_v4 = upgrade_legacy_phraser(bigram_in)
trigram_v4 = upgrade_legacy_phraser(trigram_in)
print("Upgraded:", bigram_v4, trigram_v4)

# test reload
bg = Phraser.load(bigram_v4)
tg = Phraser.load(trigram_v4)
print("Reload OK. Samples:", list(bg.phrasegrams)[:3], list(tg.phrasegrams)[:3])

# %%
# load saved (and trained) LDA model
saves_directory = os.path.join("", "./topic/saves/st")

bigram_phraser_directory = os.path.join(saves_directory, "bigram-phraser-st.v4")
bigram_phraser = Phraser.load(bigram_phraser_directory)

trigram_phraser_directory = os.path.join(saves_directory, "trigram-phraser-st.v4")
trigram_phraser = Phraser.load(trigram_phraser_directory)

lda_directory = os.path.join(saves_directory, "lda-st-40.model")
lda_st_40 = LdaModel.load(lda_directory)

lda_directory = os.path.join(saves_directory, "lda-st-30.model")
lda_st_30 = LdaModel.load(lda_directory)

lda_directory = os.path.join(saves_directory, "lda-st-50.model")
lda_st_50 = LdaModel.load(lda_directory)

# load dictionary
dictionary_directory = os.path.join(saves_directory, "trigram-dictionary-st.dict")
dictionary = Dictionary.load(dictionary_directory)

# %% [markdown]
# ### Vectorize

# %%
tokenized_contents = list()

for ix, row in df_og_article_text.iterrows():
    stdout.write("\r(%s/%s) Tokenizing datapoint" % (ix + 1, len(df_og_article_text)))

    tokens = [
        token.lemma_.lower()
        for token in nlp(
            row["content_cleaned"], disable=["tagger"]
        )  # Changed this line
        if return_token(token)
    ]

    # convert to bigram phrases
    bigram_tokens = bigram_phraser[tokens]

    # convert to trigram phrases
    trigram_tokens = trigram_phraser[bigram_tokens]

    tokenized_contents.append(trigram_tokens)

print("\nTokenized all datapoints")

# %%
vectorized_contents = [dictionary.doc2bow(doc) for doc in tokenized_contents]

# %%
df_article_k30 = get_topics(vectorized_contents, lda_st_30, "article")
df_article_k40 = get_topics(vectorized_contents, lda_st_40, "article")
df_article_k50 = get_topics(vectorized_contents, lda_st_50, "article")

# %%
df_topics = pd.concat(
    [
        # articles
        df_article_k30,
        df_article_k40,
        df_article_k50,
    ],
    axis=1,
)
df_topics.head()

# %%
df_topics_titledate = df_og_article_text.filter(["title", "date"]).merge(
    df_topics, left_index=True, right_index=True, validate="1:1"
)

df_topics_titledate

# %%
df_out = df.merge(
    df_topics_titledate, how="left", on=["title", "date"], validate="m:1"
).remove_columns(
    [
        "title",
        "date",
        "section",
        "author",
        "mp",
        "quote",
        "full_sentence",
        "matched_sentence",
        "matched_paragraph",
        "matched_fullspeech",
        "matched_speaker",
        "matched_score",
        "matched_date",
        "add_notes",
    ]
)

display(df_out.head())
df_out.info(verbose=True, show_counts=True)

# %%
df_out.to_csv(SAVEPATH, index=False)

# %%
