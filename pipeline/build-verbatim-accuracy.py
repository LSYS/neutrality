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
import numpy as np
import janitor

janitor
import warnings

warnings.filterwarnings("ignore")
from tqdm.notebook import tqdm
from IPython.display import display
from fuzzywuzzy import fuzz
import nltk

nltk.download("stopwords")
from nltk.corpus import stopwords
from utilities import load_input_data, clean_quote_speech, clean_stopwords

FP_INPUT = "../main-scripts/df-store.xlsx"
SAVEPATH = "intermediate/build-accuracy-scores.csv"

# %% [markdown]
# ## Clean speech and quote
# * remove column markers
# * remove time stamps
# * remove page stamps
# * remove strings in brackets []
# * remove strings in parenthesis ()

# %%
df = load_input_data().assign(
    quote_cleaned=lambda df_: df_["quote"].apply(clean_quote_speech),
    matched_paragraph_cleaned=lambda df_: df_["matched_paragraph"].apply(
        clean_quote_speech
    ),
    matched_sentence_cleaned=lambda df_: df_["matched_sentence"].apply(
        clean_quote_speech
    ),
    matched_fullspeech_cleaned=lambda df_: df_["matched_fullspeech"].apply(
        clean_quote_speech
    ),
)
display(df.head())
df.info()


# %% [markdown]
# ## Generating similarity scores
# * between quote and matched_sentence
# * between quote and matched_paragraph
# * between quote and matched_fullspeech
# * using fuzzywuzzy's partial string match (for the strings of length m and n (m <= n), looks for the best substring of lenght m in string n and returns this score)
# * using fuzzywuzzy's token set match (for 2 strings of length m and n (m <= n), creates a new string containing sorted intersection of substrings (s0), the 2 original strings are sorted to get s1 and s2.
# * token set match after removing stopwords

# %%
def best_partial_string_score(string1, string2):
    """
    Compute the best partial string match score between two strings.

    This function finds the optimal alignment between a shorter and longer string
    by sliding the shorter string across all possible positions in the longer
    string and computing fuzzy similarity scores at each position.

    Parameters
    ----------
    string1 : str or float
        First string for comparison. If float (NaN), indicates missing data.
    string2 : str or float
        Second string for comparison. If float (NaN), indicates missing data.

    Returns
    -------
    float
        Best partial match score between 0-100, where 100 indicates perfect match.
        Returns np.nan if either input is a float (missing data).

    Notes
    -----
    - Uses fuzzy string matching via fuzzywuzzy library's ratio function
    - When strings have equal length, returns standard ratio score
    - When strings differ in length, slides shorter string across longer string

    Examples
    --------
    >>> best_partial_string_score("cat", "the cat runs")
    100

    >>> best_partial_string_score("hello", "world")
    20

    >>> best_partial_string_score("test", np.nan)
    nan

    See Also
    --------
    fuzzywuzzy.fuzz.ratio : Standard fuzzy string ratio
    fuzzywuzzy.fuzz.partial_ratio : Built-in partial ratio function
    """
    if (type(string1) == float) or (type(string2) == float):
        return np.nan

    score = 0

    if len(string1) < len(string2):
        m = len(string1)
        n = len(string2)
        m_string = string1
        n_string = string2
    elif len(string1) > len(string2):
        m = len(string2)
        n = len(string1)
        m_string = string2
        n_string = string1
    else:
        return fuzz.ratio(string1, string2)
    for ix in range(0, n - m + 1):
        if score < fuzz.ratio(m_string, n_string[ix : ix + m]):
            score = fuzz.ratio(m_string, n_string[ix : ix + m])

    return score


# %%
text_type = ["sentence", "paragraph", "fullspeech"]

for target in tqdm(text_type):
    df[f"partialscore_quote_to_{target}"] = df.apply(
        lambda row: best_partial_string_score(
            row.quote_cleaned, row[f"matched_{target}_cleaned"]
        ),
        axis=1,
    )
    df[f"tokensetscore_quote_to_{target}"] = df.apply(
        lambda row: fuzz.token_set_ratio(
            row.quote_cleaned, row[f"matched_{target}_cleaned"]
        ),
        axis=1,
    )

# %% [markdown]
# ### No stopwords

# %%
stopwords_cache = stopwords.words("english")

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
text_type = ["sentence", "paragraph", "fullspeech"]

for target in tqdm(text_type):
    target_col = "speech" if target == "fullspeech" else target
    df[f"_partialscore_{target_col}"] = df.apply(
        lambda row: best_partial_string_score(
            row["quote_cleaned_nostopwords"],
            row[f"matched_{target}_cleaned_nostopwords"],
        ),
        axis=1,
    )
    df[f"tokensetscore_quote_to_{target}_nostopwords"] = df.apply(
        lambda row: fuzz.token_set_ratio(
            row.quote_cleaned_nostopwords, row[f"matched_{target}_cleaned_nostopwords"]
        ),
        axis=1,
    )

# %%
save_cols = [
    "qid",
    "partialscore_quote_to_sentence",
    "tokensetscore_quote_to_sentence",
    "partialscore_quote_to_paragraph",
    "tokensetscore_quote_to_paragraph",
    "partialscore_quote_to_fullspeech",
    "tokensetscore_quote_to_fullspeech",
    "_partialscore_sentence",
    "tokensetscore_quote_to_sentence_nostopwords",
    "_partialscore_paragraph",
    "tokensetscore_quote_to_paragraph_nostopwords",
    "_partialscore_speech",
    "tokensetscore_quote_to_fullspeech_nostopwords",
]

df[save_cols].to_csv(SAVEPATH, index=False)

# %%
