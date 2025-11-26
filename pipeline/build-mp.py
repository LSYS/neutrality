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
from tqdm.notebook import tqdm
from IPython.display import display
import re
import warnings

warnings.filterwarnings("ignore")

from utilities import load_input_data, add_parliament_periods

FP_MP_PARLIAMENT_METADATA = "./input/mps_data.xlsx"
SAVEPATH = "intermediate/build-mp.csv"

df = load_input_data()
display(df.head())
df.info()

# %% [markdown]
# ## Clean names

# %%
df[df["matched_date"].isnull()]

# %%
df.loc[df["qid"] == 343, "matched_date"] = pd.Timestamp("2012-01-15")

# %%
df[df["mp"].isnull()]

# %%
df.loc[df["qid"] == 3692, "mp"] = "K. Shanmugam"
df.loc[df["qid"] == 3693, "mp"] = "K. Shanmugam"


# %%
def clean_mp_name(name):
    """
    Clean and standardize Member of Parliament names.

    This function normalizes MP names by:
    1. Converting to lowercase
    2. Removing punctuation
    3. Normalizing whitespace
    4. Applying known corrections for common misspellings/variants

    Parameters
    ----------
    name : str
        The raw MP name to be cleaned

    Returns
    -------
    str
        The cleaned and standardized MP name

    Examples
    --------
    >>> clean_mp_name("Vivian Balakrishan")
    'vivian balakrishnan'

    >>> clean_mp_name("Halimah  Yacobsz!!!")
    'halimah yacob'

    >>> clean_mp_name("Tan Chuan Jin")
    'tan chuanjin'
    """
    corrections = {
        "mohammad maliki osman": "mohamad maliki osman",
        "vivian balakrishan": "vivian balakrishnan",
        "vivian balakkrishnan": "vivian balakrishnan",
        "masagos zukifli": "masagos zulkifli",
        "seaah kian peng": "seah kian peng",
        "yaaacob ibrahim": "yaacob ibrahim",
        "yaacoob ibrahim": "yaacob ibrahim",
        "halimah yacaob": "halimah yacob",
        "lim hng khiang": "lim hng kiang",
        "tan chuan jin": "tan chuanjin",
        "tharman shamnugaratnam": "tharman shanmugaratnam",
        "k shamugam": "k shanmugam",
        "sylia lim": "sylvia lim",
        "intan azura mohktar": "intan azura mokhtar",
        "ahmad modh magad": "ahmad mohd magad",
        "halimah yacobsz": "halimah yacob",
        "fatiamh lateef": "fatimah lateef",
        "chanu chun sing": "chan chun sing",
        "yacob ibrahim": "yaacob ibrahim",
        "lim swee kiak": "lim wee kiak",
        "ong ten koon": "ong teng koon",
        "jessican tan": "jessica tan",
        "masagos zulfkili": "masagos zulkifli",
        "k shanmugan": "k shanmugam",
        "ong kit chung": "ong chit chung",
        "ang moh seng": "ang mong seng",
        "kuik shuaiyin": "kuik shiaoyin",
        "lee hwee hua": "lim hwee hua",
        "ahmad magad": "ahmad mohd magad",
        "tan boon wan": "khaw boon wan",
        "s jayakumar": "jayakumar",
        "halimah yacob speaker": "halimah yacob",
        "ong soh kim": "ong soh khim",
        "ng eng henn": "ng eng hen",
        "alex yeo": "alvin yeo",
        "denise phua lay peng": "denise phua",
        "eugene tan kheng boon": "eugene tan",
        "jessica tan soon neo": "jessica tan",
        "xun xueling": "sun xueling",
    }

    cleaned_name = name.lower()
    cleaned_name = re.sub(r"[^\w\s]", "", cleaned_name)
    cleaned_name = re.sub(r"\s+", " ", cleaned_name).strip()

    for variant, correct_name in corrections.items():
        cleaned_name = cleaned_name.replace(variant, correct_name)

    return cleaned_name


# %%
df["mp_cleaned"] = df["mp"].apply(clean_mp_name)


# %% [markdown]
# ## Get porfolio

# %%
def get_highest_minrank(ranks):
    dict_minrank = {
        "pm": 1,
        "dpm": 2,
        "minister": 3,
        "actsecond": 4,
        "sms": 5,
        "mos": 6,
        "mayor": 7,
        "sps": 8,
        "parl sec": 9,
        "mp": 10,
        "nmp/ncmp": 11,
    }

    highest_rank = ranks[0]
    for i in range(len(ranks) - 1):
        if dict_minrank[highest_rank] > dict_minrank[ranks[i + 1]]:
            highest_rank = ranks[i + 1]
    return highest_rank


# %%
df_mps = (
    pd.read_excel(FP_MP_PARLIAMENT_METADATA)
    .rename_column("mps", "mp_cleaned")
    .assign(start_date=lambda df_: pd.to_datetime(df_["start_date"]))
    .assign(end_date=lambda df_: pd.to_datetime(df_["end_date"]))
)
df_mps.head()

# %%
for ix, row in tqdm(df.iterrows(), total=len(df)):
    # get mp and date
    mp = row["mp_cleaned"]
    date = row["matched_date"]

    if type(date) != pd._libs.tslib.Timestamp:  # use date if matched_date not available
        date = row["date"]

    # get subset of df_mps for mp and date
    mp_df = df_mps.query(f"mp_cleaned=='{mp}'").query(
        "start_date <= @date & end_date >= @date"
    )

    if len(mp_df) == 1:
        # set rank
        df.loc[ix, "rank"] = mp_df["rank"].values[0]
        # set portfolio
        portfolio = mp_df["ministry"].values[0]
        if type(portfolio) == str:
            df.loc[ix, portfolio] = 1
    else:
        # get rank of mp
        if len(set(mp_df["rank"].tolist())) == 1:
            df.loc[ix, "rank"] = mp_df["rank"].values[0]
        else:  # more than 1 rank/portfolio
            try:
                df.loc[ix, "rank"] = get_highest_minrank(mp_df["rank"].values)
            except IndexError:
                if mp == "lina chiam":
                    df.loc[ix, "rank"] = "ncmp"

        # set portfolio(s)
        for portfolio in mp_df["ministry"].tolist():
            if type(portfolio) == str:
                df.loc[ix, portfolio] = 1

# %%
df.head(3)

# %% [markdown]
# ## Create Speaker (of Parliament) column
# * speaker is a dummy variable = 1 if MP is a speaker of parliament.
# * speaker = 1 if speaker is indicated in add_notes, or indicated in the mp column itself (only 2 cases for Halimah Yacob)

# %%
speaker_condition = df["mp"].str.lower().str.contains("speaker") | df[
    "add_notes"
].str.lower().str.contains("speaker")

df["speaker"] = np.where(speaker_condition, 1, 0)
print("number of quotes by speakers is {}".format(len(df[df["speaker"] == 1])))

# %% [markdown]
# ## Time-invariant variables
# * age (matched_date - dob/yob)
# * tenure (matched_date - start)
# * gender
# * party
# * opposition dummy
# * race

# %%
df_mps_immutable = (
    pd.read_excel(FP_MP_PARLIAMENT_METADATA, sheet_name="Sheet2")
    .assign(
        start=lambda df_: pd.to_datetime(df_["start"]),
        dob=lambda df_: pd.to_datetime(df_["dob"]),
    )
    .rename_column("mps", "mp_cleaned")
)
df_mps_immutable.head()

# %%
df = df.merge(df_mps_immutable, how="inner", on="mp_cleaned", validate="m:1")
df.head()

# %% [markdown]
# ### Get age of MP at time of publication
# * if dob is availabe: age is matched_date - dob
# * if only yob is available: age is matched_date.year() - yob

# %%
for ix, row in tqdm(df.iterrows(), total=len(df)):
    date = row["matched_date"]
    dob = row["dob"]
    yob = row["yob"]

    # if dob is not available, use (publication year - yob)*365days
    if pd.isna(dob):
        if pd.isna(yob):
            pass
        else:
            df.loc[ix, "age"] = (date.year - yob) * 365
    else:
        timedelta = date - dob
        df.loc[ix, "age"] = timedelta.days

# %% [markdown]
# ### Get tenure
# * matched_date - start

# %%
df["tenure"] = (df["matched_date"] - df["start"]).dt.days

# %% [markdown]
# ### Create opposition and non-partisan dummy

# %%
set(df["party"].tolist())

# %%
df["opposition"] = 0
df["non-partisan"] = 0

oppositions = ("spp", "sda", "wp")

df["non-partisan"] = df["party"].str.contains("ind", na=False).astype(int)
df["opposition"] = df["party"].isin(oppositions).astype(int)

# %%
df.head()

# %% [markdown]
# ## Votes

# %%
df = add_parliament_periods(df)

# %%
df_votes = (
    pd.read_excel(FP_MP_PARLIAMENT_METADATA, sheet_name="Sheet4")
    .assign(mp_cleaned=lambda df_: df_["politician"].str.lower())
    .clean_names()
    .replace("walkover", np.nan)
)
df_votes

# %%
df = df.merge(
    (df_votes),
    how="left",
    on=["mp_cleaned", "parl"],
    validate="m:1",
).remove_columns(["politician", "ge", "constituency", "type"])
df.head()

# %%
_qids = [
    5043, 5044, 5045, 5046, 5047, 5048, 5049,
    5380, 5381, 5382, 5383, 5384,
    5390, 5391, 5392, 5393,
    5408, 5409, 5410,
    5531, 5532,
    5939, 5940, 5941, 5942, 5943,
    6157, 6158,
]

df.loc[df["qid"].isin(_qids), "rank"] = "minister"
df.loc[df["qid"].isin([14001, 14002]), "rank"] = "nmp"
df.loc[df["qid"].isin([14033, 14034, 14035, 14391]), "rank"] = "nmp"
df.loc[df["qid"].isin([14058, 14059, 14060]), "rank"] = "nmp"
df.loc[df["qid"].isin([14886]), "rank"] = "nmp"
df.loc[df["qid"].isin([14611]), "rank"] = "nmp"

# %%
(
    df.assign(
        mp=lambda df_: pd.factorize(df_["mp_cleaned"])[0],
    )
    .remove_columns(
        [
            "quote",
            "add_notes",
            "full_sentence",
            "matched_sentence",
            "matched_paragraph",
            "matched_fullspeech",
            "title",
            "matched_speaker",
            "mp_cleaned",
            "author",
        ]
    )
    .to_csv(SAVEPATH, index=False)
)

# %%

# %%

# %%

# %%
