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
from IPython.display import display
import janitor

janitor
import warnings

warnings.filterwarnings("ignore")

# %%
MERGE_OPTS = dict(on="qid", how="inner", validate="1:1")

df = (
    pd.read_csv("intermediate/build-mp.csv")
    .merge(pd.read_csv("intermediate/build-verbatim-accuracy-scores.csv"), **MERGE_OPTS)
    .merge(pd.read_parquet("intermediate/build-2stage-semsim.parquet"), **MERGE_OPTS)
    .merge(pd.read_csv("intermediate/build-article.csv"), **MERGE_OPTS)
    .merge(pd.read_csv("intermediate/build-article-topics.csv"), **MERGE_OPTS)
    .merge(pd.read_parquet("intermediate/build-speech-topics.parquet"), **MERGE_OPTS)
    .merge(pd.read_csv("intermediate/build-linguistics.csv"), **MERGE_OPTS)
)

display(df.head())

# %%
df.to_parquet("./out/media.parquet", index=False)
df.to_stata("./out/media.dta", write_index=False, version=114)

# %%
