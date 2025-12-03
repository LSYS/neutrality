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

from utilities import load_input_data, clean_quote_speech, return_token, get_topics

SAVEPATH = "intermediate/build-speech-topics.parquet"

from sys import stdout
import spacy

nlp = spacy.load("en_core_web_sm")

import pickle
from gensim.models.phrases import Phrases, Phraser
from gensim.corpora import MmCorpus
from gensim.models.ldamodel import LdaModel
from gensim.corpora import Dictionary

df = load_input_data().assign(
    quote_cleaned=lambda df_: df_["quote"].apply(clean_quote_speech),
    matched_fullspeech_cleaned=lambda df_: df_["matched_fullspeech"].apply(
        clean_quote_speech
    ),
    matched_sentence=lambda df_: df_["matched_sentence"].apply(clean_quote_speech),
)
display(df.head())
df.info()


# %% [markdown]
# ## Load models

# %% [markdown]
# ### Update

# %%
def _to_str(x):
    if isinstance(x, bytes):
        return x.decode("utf8", "ignore")
    return str(x) if not isinstance(x, str) else x


def upgrade_legacy_phraser(in_path, out_path=None):
    """
    Load a Py2-era gensim Phrases/Phraser pickle, normalize its phrasegrams,
    and save a fresh gensim-4 Phraser at `out_path` (default: in_path + '.v4').
    """
    # try gensim loader first
    obj = None
    for loader in (Phraser.load, Phrases.load):
        try:
            obj = loader(in_path)
            break
        except Exception:
            pass
    if obj is None:
        # raw Py2 pickle
        with open(in_path, "rb") as f:
            obj = pickle.load(f, encoding="latin1")

    # get phrasegrams & delimiter
    pg = getattr(obj, "phrasegrams", None)
    if pg is None:
        raise ValueError(f"{in_path}: no phrasegrams attribute; not a Phraser/Phrases?")

    delim = getattr(obj, "delimiter", b"_")
    if isinstance(delim, bytes):
        delim_bytes = delim
        delim_str = delim.decode("utf8", "ignore")
    else:
        delim_str = _to_str(delim)
        delim_bytes = delim_str.encode("utf8")

    # normalize mapping → { "token1_token2": float(score), ... }
    norm_pg = {}
    for k, v in pg.items():
        # score may be a tuple; keep its last element (score)
        if isinstance(v, tuple):
            v = v[-1]
        # keys may be tuple-of-bytes/str, bytes, or str
        if isinstance(k, tuple):
            key_str = delim_str.join(_to_str(part) for part in k)
        elif isinstance(k, (bytes, str)):
            key_str = _to_str(k)
        else:
            key_str = _to_str(k)
        norm_pg[key_str] = float(v)

    # build a fresh gensim-4 Phraser and inject the normalized table
    base_phrases = Phrases([[]], delimiter=delim_bytes)  # minimal valid phrases
    new_phraser = Phraser(base_phrases)
    new_phraser.delimiter = delim_bytes
    new_phraser.phrasegrams = norm_pg

    if out_path is None:
        out_path = in_path + ".v4"
    new_phraser.save(out_path)
    return out_path


base = "./topic/saves/hansard"
bigram_in = os.path.join(base, "bigram-phraser-hansard")
trigram_in = os.path.join(base, "trigram-phraser-hansard")

bigram_v4 = upgrade_legacy_phraser(bigram_in)
trigram_v4 = upgrade_legacy_phraser(trigram_in)
print("Upgraded:", bigram_v4, trigram_v4)

# test reload
bg = Phraser.load(bigram_v4)
tg = Phraser.load(trigram_v4)
print("Reload OK. Samples:", list(bg.phrasegrams)[:3], list(tg.phrasegrams)[:3])

# %% [markdown]
# ### Load models

# %%
# # load saved (and trained) LDA model
saves_directory = os.path.join("", "./topic/saves/hansard")

bigram_phraser_directory = os.path.join(saves_directory, "bigram-phraser-hansard.v4")
bigram_phraser = Phraser.load(bigram_phraser_directory)

trigram_phraser_directory = os.path.join(saves_directory, "trigram-phraser-hansard.v4")
trigram_phraser = Phraser.load(trigram_phraser_directory)

lda_directory = os.path.join(saves_directory, "lda-hansard-92.model")
lda_92 = LdaModel.load(lda_directory)

lda_directory = os.path.join(saves_directory, "lda-hansard-50.model")
lda_50 = LdaModel.load(lda_directory)

lda_directory = os.path.join(saves_directory, "lda-hansard-100.model")
lda_100 = LdaModel.load(lda_directory)

# load dictionary
dictionary_directory = os.path.join(saves_directory, "trigram-dictionary-hansard.dict")
dictionary = Dictionary.load(dictionary_directory)

# %% [markdown]
# ## Vectorize

# %% [markdown]
# ### Speech

# %% code_folding=[]
# tokenized corpus
tokenized_speeches = list()

for ix, row in df.iterrows():
    stdout.flush()
    stdout.write("\r(%s/%s) Tokenizing datapoint" % (ix + 1, len(df)))

    # Tokenizing document
    tokens = [
        token.lemma_.lower()
        for token in nlp(df.loc[ix, "matched_fullspeech_cleaned"], disable=["tagger"])
        if return_token(token)
    ]

    # convert to bigram phrases
    bigram_tokens = bigram_phraser[tokens]

    # convert to trigram phrases
    trigram_tokens = trigram_phraser[bigram_tokens]

    tokenized_speeches.append(trigram_tokens)

print("\nTokenized all datapoints")

# %%
trigram_speech_directory = os.path.join("intermediate", "df-speech-st")

with open(trigram_speech_directory, "wb") as f:
    pickle.dump(tokenized_speeches, f)

# %%
vectorized_speeches = [dictionary.doc2bow(doc) for doc in tokenized_speeches]
vectorized_speech_directory = os.path.join("intermediate", "df-speech-st.mm")
MmCorpus.serialize(vectorized_speech_directory, vectorized_speeches)

# %% [markdown]
# ### Quotes

# %% code_folding=[]
# tokenized quotes
tokenized_quotes = list()

for ix, row in df.iterrows():
    stdout.flush()
    stdout.write("\r(%s/%s) Tokenizing datapoint" % (ix + 1, len(df)))

    # Tokenizing document
    tokens = [
        token.lemma_.lower()
        for token in nlp(row["quote_cleaned"], disable=["tagger"])
        if return_token(token)
    ]

    # convert to bigram phrases
    bigram_tokens = bigram_phraser[tokens]

    # convert to trigram phrases
    trigram_tokens = trigram_phraser[bigram_tokens]

    tokenized_quotes.append(trigram_tokens)

print("\nTokenized all datapoints")

# %%
trigram_quote_directory = os.path.join("intermediate", "df-quote-st")

with open(trigram_quote_directory, "wb") as f:
    pickle.dump(tokenized_quotes, f)

# %%
vectorized_quotes = [dictionary.doc2bow(doc) for doc in tokenized_quotes]
vectorized_quote_directory = os.path.join("intermediate", "df-quote-st.mm")
MmCorpus.serialize(vectorized_quote_directory, vectorized_quotes)

# %% [markdown]
# ### Sentences

# %%
# tokenized matched sentence
tokenized_sent = list()

for ix, row in df.iterrows():
    stdout.flush()
    stdout.write("\r(%s/%s) Tokenizing datapoint" % (ix + 1, len(df)))

    try:
        # Tokenizing document
        tokens = [
            token.lemma_.lower()
            for token in nlp(row["matched_sentence"], disable=["tagger"])
            if return_token(token)
        ]

        # convert to bigram phrases
        bigram_tokens = bigram_phraser[tokens]

        # convert to trigram phrases
        trigram_tokens = trigram_phraser[bigram_tokens]

        tokenized_sent.append(trigram_tokens)
    except ValueError:
        continue

print("\nTokenized all datapoints")

# %%
trigram_quote_directory = os.path.join("intermediate", "df-sent-st")

with open(trigram_quote_directory, "wb") as f:
    pickle.dump(tokenized_sent, f)

# %%
vectorized_quotes = [dictionary.doc2bow(doc) for doc in tokenized_sent]
vectorized_quote_directory = os.path.join("intermediate", "df-sent-st.mm")
MmCorpus.serialize(vectorized_quote_directory, vectorized_quotes)

# %% [markdown]
# ### k* = 92

# %%
df_speech_k92 = get_topics(vectorized_speeches, lda_92, "speech")
df_quote_k92 = get_topics(vectorized_quotes, lda_92, "quote")
df_sentence_k92 = get_topics(vectorized_quotes, lda_92, "sentence")

# %% [markdown]
# ### k = 50

# %%
df_speech_k50 = get_topics(vectorized_speeches, lda_50, "speech")
df_quote_k50 = get_topics(vectorized_quotes, lda_50, "quote")

# %% [markdown]
# ### k = 100

# %%
df_speech_k100 = get_topics(vectorized_speeches, lda_100, "speech")
df_quote_k100 = get_topics(vectorized_quotes, lda_100, "quote")

# %%
df_out = pd.concat(
    [
        df["qid"],
        df_speech_k92,
        df_quote_k92,
        df_speech_k50,
        df_quote_k50,
        df_speech_k100,
        df_quote_k100,
        df_sentence_k92,
    ],
    axis=1,
)
display(df_out.head())
df_out.info(verbose=True)

# %%
df_out.to_parquet(SAVEPATH, index=False)

# %%
