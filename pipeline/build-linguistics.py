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
import janitor

janitor
from IPython.display import display
import numpy as np
from textatistic import Textatistic
from lexicalrichness import LexicalRichness
from textblob import TextBlob

from textblob.sentiments import PatternAnalyzer
import time

# from sys import stdout
import warnings

warnings.filterwarnings("ignore")
from tqdm.notebook import tqdm
from utilities import load_input_data, clean_quote_speech_preserve_sentences

SAVEPATH = "intermediate/build-linguistics.csv"

# %%
df = (
    load_input_data().assign(
    matched_fullspeech_cleaned=lambda df_: df_["matched_fullspeech"].apply(
        clean_quote_speech_preserve_sentences
    ),
    matched_paragraph_cleaned=lambda df_: df_["matched_paragraph"].apply(
        clean_quote_speech_preserve_sentences
    ),
    matched_sentence_cleaned=lambda df_: df_["matched_sentence"].apply(
        clean_quote_speech_preserve_sentences
    ),
    quote_cleaned=lambda df_: df_["quote"].apply(clean_quote_speech_preserve_sentences),
    full_sentence_cleaned=lambda df_: df_["full_sentence"].apply(
        clean_quote_speech_preserve_sentences
    ),
    )
    .assign(
        speech_id=lambda df_: pd.factorize(df_["matched_fullspeech_cleaned"])[0],
    )
)
display(df.head())
df.info()

# %% [markdown]
# ## Lexical Richness
#
# [https://github.com/lsys/lexicalrichness](https://github.com/lsys/lexicalrichness)

# %%
time_start = time.time()

for ix, row in tqdm(df.iterrows(), total=len(df)):
    try:
        lex = LexicalRichness(row["matched_fullspeech_cleaned"])

        df.at[ix, "ttr"] = lex.ttr
        df.at[ix, "rttr"] = lex.rttr
        df.at[ix, "cttr"] = lex.cttr

        df.at[ix, "herdan"] = lex.Herdan
        df.at[ix, "summer"] = lex.Summer

        try:
            df.at[ix, "dugast"] = lex.Dugast
        except ZeroDivisionError:
            df.at[ix, "dugast"] = np.nan
        except Exception as e:
            print(f"\ndugast error at {ix}: {e}")
            df.at[ix, "dugast"] = np.nan

        df.at[ix, "maas"] = lex.Maas

        # msttr
        try:
            df.at[ix, "msttr"] = lex.msttr(segment_window=100, discard=True)
        except ValueError:
            df.at[ix, "msttr"] = lex.ttr
        except Exception as e:
            print(f"\nmsttr error at {ix}: {e}")
            df.at[ix, "msttr"] = np.nan

        # mattr
        try:
            df.at[ix, "mattr"] = lex.mattr(window_size=100)
        except ValueError:
            df.at[ix, "mattr"] = lex.ttr
        except Exception as e:
            print(f"\nmattr error at {ix}: {e}")
            df.at[ix, "mattr"] = np.nan

        # mtld
        df.at[ix, "mtld"] = lex.mtld(threshold=0.72)

        # hdd
        try:
            df.at[ix, "hdd"] = lex.hdd(draws=42)
        except ValueError:
            df.at[ix, "hdd"] = np.nan
        except Exception as e:
            print(f"\nhdd error at {ix}: {e}")
            df.at[ix, "hdd"] = np.nan

    except Exception as e:
        # Handle cases where LexicalRichness fails entirely (e.g., empty text)
        print(f"\nLexicalRichness initialization error at {ix}: {e}")
        df.at[ix, "ttr"] = np.nan
        df.at[ix, "rttr"] = np.nan
        df.at[ix, "cttr"] = np.nan
        df.at[ix, "herdan"] = np.nan
        df.at[ix, "summer"] = np.nan
        df.at[ix, "dugast"] = np.nan
        df.at[ix, "maas"] = np.nan
        df.at[ix, "msttr"] = np.nan
        df.at[ix, "mattr"] = np.nan
        df.at[ix, "mtld"] = np.nan
        df.at[ix, "hdd"] = np.nan

print(f"\ncompleted in {(time.time() - time_start) / 60:.3f} mins")

# %% [markdown]
# ## Objectivity & sentiment
#
# Using off-the-shelf classifiers from TextBlob (https://github.com/sloria/TextBlob)

# %% [markdown]
# ### PatternAnalyzer from Pattern
# * (https://www.clips.uantwerpen.be/pattern), poor documentation though
# * polarity and subjectivity scores from -1.0 to 1.0

# %%
for ix, row in tqdm(df.iterrows(), total=len(df)):
    # for speech
    blob = TextBlob(row["matched_fullspeech_cleaned"], analyzer=PatternAnalyzer())
    df.at[ix, "speech_polarity"] = blob.sentiment.polarity
    df.at[ix, "speech_subjectivity"] = blob.sentiment.subjectivity

    # for paragraph
    try:
        blob = TextBlob(row["matched_paragraph_cleaned"], analyzer=PatternAnalyzer())
        df.at[ix, "para_polarity"] = blob.sentiment.polarity
        df.at[ix, "para_subjectivity"] = blob.sentiment.subjectivity
    except TypeError:
        df.at[ix, "para_polarity"] = np.nan
        df.at[ix, "para_subjectivity"] = np.nan

    # for sentence
    try:
        blob = TextBlob(row["matched_sentence_cleaned"], analyzer=PatternAnalyzer())
        df.at[ix, "sentence_polarity"] = blob.sentiment.polarity
        df.at[ix, "sentence_subjectivity"] = blob.sentiment.subjectivity
    except TypeError:
        df.at[ix, "sentence_polarity"] = np.nan
        df.at[ix, "sentence_subjectivity"] = np.nan
        print(f"\nError at {ix}")

    # for quote
    blob = TextBlob(row["quote_cleaned"], analyzer=PatternAnalyzer())
    df.at[ix, "quote_polarity"] = blob.sentiment.polarity
    df.at[ix, "quote_subjectivity"] = blob.sentiment.subjectivity

    # for sentence (containing quote)
    try:
        blob = TextBlob(row["full_sentence_cleaned"], analyzer=PatternAnalyzer())
        df.at[ix, "quote_sentence_polarity"] = blob.sentiment.polarity
        df.at[ix, "quote_sentence_subjectivity"] = blob.sentiment.subjectivity
    except TypeError:
        df.at[ix, "quote_sentence_polarity"] = np.nan
        df.at[ix, "quote_sentence_subjectivity"] = np.nan

# %% [markdown]
# ## Readability

# %%
# https://stackoverflow.com/questions/2718196/find-all-chinese-text-in-a-string-using-python-and-regex
# RE = re.compile(u'[⺀-⺙⺛-⻳⼀-⿕々〇〡-〩〸-〺〻㐀-䶵一-鿃豈-鶴侮-頻並-龎]', re.UNICODE)

# df['matched_fullspeech'] = df['matched_fullspeech'].apply(lambda x:
#                                                           RE.sub('', x))

# %%
time_start = time.time()
for ix, row in tqdm(df.iterrows(), total=len(df)):
    try:
        # create Textatistic instance
        t = Textatistic(row["matched_fullspeech_cleaned"])
        # store readability measures to df using .at[] or .loc[]
        df.at[ix, "dalechall"] = t.dalechall_score
        df.at[ix, "flesch"] = t.flesch_score
        df.at[ix, "fleschkincaid"] = t.fleschkincaid_score
        df.at[ix, "gunningfog"] = t.gunningfog_score
        df.at[ix, "smog"] = t.smog_score
        df.at[ix, "notdalechall"] = t.notdalechall_count
        df.at[ix, "polysyllable"] = t.polysyblword_count
        df.at[ix, "syllables"] = t.sybl_count
        df.at[ix, "sentences"] = t.sent_count
    except Exception as e:
        print(f"\nError at {ix}: {e}")

print("completed in {0:.3f} mins".format((time.time() - time_start) / 60))

# %%
df.info()

# %%
cols = [
    "qid",
    "speech_id",
    "ttr",
    "rttr",
    "cttr",
    "herdan",
    "summer",
    "dugast",
    "maas",
    "msttr",
    "mattr",
    "mtld",
    "hdd",
    "speech_polarity",
    "speech_subjectivity",
    "para_polarity",
    "para_subjectivity",
    "sentence_polarity",
    "sentence_subjectivity",
    "quote_polarity",
    "quote_subjectivity",
    "quote_sentence_polarity",
    "quote_sentence_subjectivity",
    "dalechall",
    "flesch",
    "fleschkincaid",
    "gunningfog",
    "smog",
    "notdalechall",
    "polysyllable",
    "syllables",
    "sentences",
]
df[cols].to_csv(SAVEPATH, index=False)

# %%
