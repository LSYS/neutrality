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
import janitor

janitor
import re
import warnings

warnings.filterwarnings("ignore")
from tqdm.notebook import tqdm
from IPython.display import display
import numpy as np
from utilities import load_input_data, clean_quote_speech_preserve_sentences

# import torch

from sentence_transformers import SentenceTransformer, CrossEncoder
from transformers import AutoTokenizer
import hashlib

# %%
# torch.set_num_threads(os.cpu_count() or 4)
os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")

# -------- Models ----------
BI_NAME = "sentence-transformers/all-mpnet-base-v2"
CE_NAME = "cross-encoder/ms-marco-MiniLM-L12-v2"

bi = SentenceTransformer(BI_NAME, device="cpu")
ce = CrossEncoder(CE_NAME, device="cpu", max_length=512)
tok = AutoTokenizer.from_pretrained(BI_NAME)

tokenizer = ce.tokenizer

# confirm max_position_embeddings
max_tokens = tokenizer.model_max_length
print(f"Model max tokens: {max_tokens}")

# %%
df = (
    load_input_data()
    .sort_values(["title", "date"], ignore_index=True)
    .assign(
        quote_cleaned=lambda df_: df_["quote"].apply(
            clean_quote_speech_preserve_sentences
        ),
        full_sentence_cleaned=lambda df_: df_["full_sentence"].apply(
            clean_quote_speech_preserve_sentences
        ),
        matched_fullspeech_cleaned=lambda df_: df_["matched_fullspeech"].apply(
            clean_quote_speech_preserve_sentences
        ),
    )
)
display(df)
df.info()


# %% [markdown]
# ## Helpers

# %% code_folding=[]
# Helpers
def split_sentences(text):
    """
    Split text into sentences using regex pattern matching.

    Parameters
    ----------
    text : str
        Input text to split into sentences

    Returns
    -------
    list of str
        List of cleaned sentences. Returns empty list if no text,
        or single-item list with original text if no sentence boundaries found.

    Examples
    --------
    >>> split_sentences("Hello world. How are you? Fine!")
    ['Hello world.', 'How are you?', 'Fine!']
    >>> split_sentences("")
    []
    """
    _SENT_SPLIT = re.compile(r"(?<=[.!?])\s+")

    if not text:
        return []
    s = [t.strip() for t in _SENT_SPLIT.split(text) if t.strip()]
    return s if s else [text.strip()]


CACHE_DIR = "./sent_cache_npz"
os.makedirs(CACHE_DIR, exist_ok=True)


def speech_id(text):
    """
    Generate a unique cache identifier for speech text using MD5 hash.

    Parameters
    ----------
    text : str
        Speech text to generate ID for

    Returns
    -------
    str
        MD5 hexdigest of the text (32 character string)
    """
    return hashlib.md5(text.encode("utf-8")).hexdigest()


def load_sent_cache(spid):
    """
    Load cached sentence embeddings from disk.

    Parameters
    ----------
    spid : str
        Speech ID (cache key) to load

    Returns
    -------
    sentences : list of str or None
        List of sentence strings, None if cache miss
    embeddings : ndarray or None
        Sentence embedding matrix of shape (n_sentences, embedding_dim),
        None if cache miss

    Notes
    -----
    Cache files are stored as compressed .npz files.
    """
    p = os.path.join(CACHE_DIR, spid + ".npz")
    if not os.path.exists(p):
        return None, None

    d = np.load(p, allow_pickle=False)
    return d["sents"].astype(str).tolist(), d["emb"]


def save_sent_cache(spid, sents, emb):
    """
    Save sentence embeddings to disk cache.

    Parameters
    ----------
    spid : str
        Speech ID (cache key) to save under
    sents : list of str
        List of sentence strings
    emb : ndarray
        Sentence embedding matrix of shape (n_sentences, embedding_dim)

    Notes
    -----
    Saves in compressed .npz format without pickle for security.
    Sentences are stored as Unicode string arrays.
    """
    p = os.path.join(CACHE_DIR, spid + ".npz")
    # save as fixed-width Unicode dtype, not object
    np.savez_compressed(p, sents=np.array(sents, dtype=np.unicode_), emb=emb)


def get_speech_sentence_embeds(speech_text, batch_size=128):
    """
    Get or compute sentence embeddings for a speech text with caching.

    Parameters
    ----------
    speech_text : str
        Full speech text to process
    batch_size : int, default=128
        Batch size for sentence embedding computation

    Returns
    -------
    spid : str
        Speech ID (cache key)
    sents : list of str
        List of individual sentences
    emb : ndarray or None
        Sentence embedding matrix of shape (n_sentences, embedding_dim).
        None if no sentences found.

    Notes
    -----
    Uses bi-encoder model to compute embeddings. Results are cached to disk
    for faster subsequent access. Embeddings are L2-normalized.
    """
    spid = speech_id(speech_text)

    # Try loading from cache
    sents, emb = load_sent_cache(spid)
    if sents is not None:
        return spid, sents, emb

    # Compute embeddings if not cached yet
    sents = split_sentences(speech_text)
    if not sents:
        return spid, [], None
    emb = bi.encode(
        sents,
        convert_to_numpy=True,
        normalize_embeddings=True,
        batch_size=batch_size,
        show_progress_bar=False,
    )
    save_sent_cache(spid, sents, emb)
    return spid, sents, emb


def build_pair_window(
    sent_list, center_idx, tokenizer, quote_ids, max_pair_len=512, left=5, right=5
):
    """
    Build a context window around a center sentence within token budget.

    Expands symmetrically around center sentence while staying within the
    token budget for cross-encoder input (quote + window + special tokens).

    Parameters
    ----------
    sent_list : list of str
        List of all sentences in the speech
    center_idx : int
        Index of the center sentence to build window around
    tokenizer : transformers.AutoTokenizer
        Tokenizer to count tokens for budget management
    quote_ids : list of int
        Token IDs of the quote (to reserve space in budget)
    max_pair_len : int, default=512
        Maximum total tokens for cross-encoder input
    left : int, default=3
        Maximum sentences to include left of center
    right : int, default=3
        Maximum sentences to include right of center

    Returns
    -------
    str
        Concatenated window text that fits within token budget

    Notes
    -----
    Reserves ~3 tokens for special tokens ([CLS], [SEP], etc.).
    If quote is very long, falls back to minimum 32-token window.
    """
    # CE uses [CLS] quote [SEP] window [SEP] => reserve ~3 specials
    budget = max_pair_len - 3 - len(quote_ids)
    if budget <= 32:  # quote is huge; give a tiny window
        budget = 32
    # expand around center under budget
    start = max(0, center_idx - left)
    end = min(len(sent_list), center_idx + right + 1)
    chosen, used = [], 0
    for i in range(start, end):
        ids = tokenizer.encode(sent_list[i], add_special_tokens=False)
        if used + len(ids) <= budget:
            chosen.append(sent_list[i])
            used += len(ids)
        else:
            break
    return " ".join(chosen)


# -------- Two-stage + CE on CPU ----------
_quote_cache = {}

ce_tok = getattr(ce, "tokenizer", None) or AutoTokenizer.from_pretrained(CE_NAME)


def two_stage_ce_cpu(
    quote_text,
    speech_text,
    k_sent=5,
    flank_left=3,
    flank_right=3,
    max_pair_len=512,
    ce_batch=16,
    use_sigmoid=True,
):
    """
    Two-stage semantic similarity between quote and speech using bi-encoder + cross-encoder.

    Stage 1: Use bi-encoder to find top-k most similar sentences in speech.
    Stage 2: Use cross-encoder to rerank context windows around top sentences.

    Parameters
    ----------
    quote_text : str
        Quote text to find in speech
    speech_text : str
        Full speech text to search within
    k_sent : int, default=5
        Number of top sentences to retrieve in stage 1
    flank_left : int, default=3
        Maximum sentences to include left of center in windows
    flank_right : int, default=3
        Maximum sentences to include right of center in windows
    ce_batch : int, default=16
        Batch size for cross-encoder scoring
    use_sigmoid : bool, default=True
        Whether to apply sigmoid activation to cross-encoder scores

    Returns
    -------
    dict or None
        Dictionary containing similarity metrics:
        - 'be_max': Maximum bi-encoder similarity score
        - 'ce_max': Maximum cross-encoder score
        - 'ce_avg': Softmax-weighted average cross-encoder score
        - 'be_coverage': Fraction of sentences above coverage threshold
        - 'best_window': Text of highest-scoring context window
        - 'top_sent_idx': Indices of top-k sentences from bi-encoder
        - 'num_ce_pairs': Number of quote-window pairs scored

        Returns None if inputs are empty or processing fails.

    Notes
    -----
    Uses caching for both sentence embeddings and quote embeddings.
    Applies sigmoid activation only to ms-marco cross-encoder models.
    Coverage is computed using bi-encoder similarities across all sentences.

    Examples
    --------
    >>> result = two_stage_ce_cpu("democracy is important", full_speech_text)
    >>> print(f"Best match score: {result['ce_max']:.3f}")
    >>> print(f"Coverage: {result['be_coverage']:.1%}")
    """
    if not quote_text or not speech_text:
        return None

    # Stage 1: sentence embeddings (cached)
    spid, sents, S = get_speech_sentence_embeds(speech_text)
    if S is None or len(sents) == 0:
        return None

    # Quote embedding (cached)
    q = _quote_cache.get(quote_text)
    if q is None:
        q = bi.encode(
            quote_text, convert_to_numpy=True, normalize_embeddings=True, batch_size=1
        )
        _quote_cache[quote_text] = q
    q = np.ravel(q)

    # Bi-encoder sims and top-k
    sims = S @ q
    k = min(k_sent, sims.size)
    top_idx = np.argpartition(sims, -k)[-k:]
    top_idx = top_idx[np.argsort(sims[top_idx])[::-1]]

    # Windows for CE
    quote_ids = ce_tok.encode(quote_text, add_special_tokens=False)
    windows, seen = [], set()
    for idx in top_idx:
        w = build_pair_window(
            sents,
            int(idx),
            ce_tok,
            quote_ids,
            max_pair_len=max_pair_len,
            left=flank_left,
            right=flank_right,
        )
        if w and w not in seen:
            windows.append(w)
            seen.add(w)

    coarse = float(sims.max()) if sims.size else np.nan
    if not windows:
        return {"be_max": coarse, "ce_max": np.nan, "best_window": np.nan}

    # CE scoring
    pairs = [(quote_text, w) for w in windows]
    ce_scores = np.asarray(ce.predict(pairs, batch_size=ce_batch), dtype=float)

    # Optional sigmoid for ms-marco-style logits (keep if you use such CEs)
    if use_sigmoid and "ms-marco" in CE_NAME.lower():
        ce_scores = 1 / (1 + np.exp(-ce_scores))

    j = int(np.argmax(ce_scores))
    return {
        "be_max": coarse,
        "ce_max": float(ce_scores[j]),
        "best_window": windows[j],
    }


# %% [markdown]
# ## Compute

# %%
# Init columns
semsim_scores = [
    "be_max_quote2speech",
    "ce_max_quote2speech",
]

for measure in semsim_scores:
    df[measure] = np.nan

# %%
for row in tqdm(df.itertuples(index=True), total=len(df)):
    ix = row.Index
    if df.loc[ix, semsim_scores].isna().any():
        # quote -> SPEECH
        out = two_stage_ce_cpu(
            row.quote_cleaned,
            row.matched_fullspeech_cleaned,
            k_sent=10,
            flank_left=5,
            flank_right=5,
        )
        if out:
            df.at[ix, "be_max_quote2speech"] = out["be_max"]
            df.at[ix, "ce_max_quote2speech"] = out["ce_max"]
            df.at[ix, "best_window_quote2speech"] = out["best_window"]

    if ix % 3000 == 0 and ix > 0:
        df[semsim_scores].to_csv("2stage_backup.csv", index=False)

# %%
df[["qid", *semsim_scores]].to_parquet(
    "intermediate/build-2stage-semsim.parquet", index=False
)

# %%
