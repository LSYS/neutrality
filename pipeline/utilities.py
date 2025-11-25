import datetime
import pickle
import re
import string

import numpy as np
import pandas as pd
from gensim.models.phrases import Phraser, Phrases


def remove_punctuation_whitespace(word):
    """Replaces punctuation with whitespace to deal with contractions. E.g., don't becomes
    don t, which would evaluate to a length of 2 words, as it should be.
    """
    for p in list(string.punctuation):
        word = word.replace(p, " ")
    return word


def clean_quote_speech(text):
    """Takes a string var as argument, process it using regex, and returns a string (all in lowercase)."""
    pattern1 = "page:\s*?[0-9]+"  # page makers e.g. page: xx
    pattern2 = "[0-9]+[.:]\s*?[0-9]+\s*?pm"  # timestamp e.g. 5.55 pm
    pattern3 = "[0-9]+[.:]\s*?[0-9]+\s*?am"  # timestamp e.g. 11:00 am
    pattern4 = "column:\s*?[0-9]+"  # column makers e.g. column: xxxx
    pattern5 = "\(.+\)"  # remove anything in parentheses
    pattern6 = "\[.+\]"  # remove anything in brackets
    pattern = "|".join((pattern1, pattern2, pattern3, pattern4, pattern5, pattern6))
    if pd.isna(text):
        return np.nan
    try:
        text = re.sub(pattern, "", text.lower())
    except AttributeError:
        pass
    text = remove_punctuation_whitespace(text)
    text = re.sub("\s+", " ", text)
    return text


def clean_stopwords(text, stopwords_set):
    """Removes stopwords from text and normalizes whitespace."""
    if pd.isna(text):
        return text
    cleaned = " ".join([word for word in text.split() if word not in stopwords_set])
    return re.sub(r"\s+", " ", cleaned).strip()


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


def load_input_data(filepath="./input/df-store.xlsx"):
    """
    Load and preprocess matched corpus from Excel file.

    This function:
    1. Reads Excel file from the given filepath
    2. Removes unwanted columns ('ix', 'ix.1')
    3. Converts date columns to datetime
    4. Normalizes title column to lowercase
    5. Cleans MP names using clean_mp_name function
    6. Sorts by title and date

    Parameters
    ----------
    filepath : str
        Path to the Excel file to be loaded

    Returns
    -------
    pd.DataFrame
        Processed dataframe ready for analysis
    """
    df = (
        pd.read_excel(filepath)
        .rename_column("ix", "qid")
        .remove_columns("ix.1")
        .assign(
            matched_date=lambda df_: pd.to_datetime(df_["matched_date"]),
            date=lambda df_: pd.to_datetime(df_["date"]),
        )
        .assign(title=lambda df_: df_["title"].str.lower())
        # .sort_values(["title", "date"], ignore_index=True)
    )
    print("length of raw dataframe is {}".format(len(df)))
    return df


def clean_content(text):
    """
    Remove punctuation and normalize whitespace from text.

    Parameters
    ----------
    text : str
        The text to be cleaned

    Returns
    -------
    str
        Text with punctuation removed and whitespace normalized
    """
    # remove punctuations
    for p in list(string.punctuation):
        text = text.replace(p, "")
    text = re.sub("\s+", " ", text).strip()
    return text


def return_token(token):
    """
    Checks if a token (of type spacy.tokens.token.Token) meets certain exclusion criteria using spacy.
    If yes, then return false, return true otherwise.
    Exclusion criteria are:
        (i)   entity types of person, date, time, etc.
        (ii)  punctuation
        (iii) stopword
    Entity types found here: https://spacy.io/usage/linguistic-features
    Argument:
        spacy.tokens.token.Token object.
    Return:
        Boolean.
    """
    entity_types = [
        "PERSON",
        "DATE",
        "TIME",
        "PERCENT",
        "MONEY",
        "QUANTITY",
        "ORDINAL",
        "CARDINAL",
    ]
    if token.ent_type_ in entity_types:
        return False
    if token.is_punct:
        return False
    if token.is_stop:
        return False
    return True


def clean_speech(speech):
    """Clean speeches from parliament transcript.
    Removes:
        (i)   Timestamps
        (ii)  column markers
        (iii) page markers
        (iv)  remove strings in parentheses and brackets
        (v)   strang non-english characters
        (vi)  digits
        (vii) whitespaces
    Argument:
        speech is a unicode/str variable (needs unicode for further spacy processing)
    Return:
        unicode/str var
    """
    # remove strange non-eng characters
    speech = "".join([char for char in speech if char in string.printable])
    # remove transcript markers
    pattern1 = "page:\s*?[0-9]+"  # page makers e.g. page: xx
    pattern2 = "[0-9]+[.:]\s*?[0-9]+\s*?pm"  # timestamp e.g. 5.55 pm
    pattern3 = "[0-9]+[.:]\s*?[0-9]+\s*?am"  # timestamp e.g. 11:00 am
    pattern4 = "column:\s*?[0-9]+"  # column makers e.g. column: xxxx
    pattern5 = "\(.+\)"  # remove anything in parentheses
    pattern6 = "\[.+\]"  # remove anything in brackets
    pattern = "|".join((pattern1, pattern2, pattern3, pattern4, pattern5, pattern6))
    speech = re.sub(pattern, " ", speech)
    # remove digits
    speech = re.sub(r"[0-9]+", " ", speech)
    # remove whitespaces
    speech = re.sub("\s+", " ", speech)
    return speech


def get_topics(corpus, lda, content_type=""):
    """
    Get topic distribution for corpus.
    Parameter:
        corpus: List of lists of vectorized corpus (e.g. [[(2, 1)],
                                                          [(0, 1), (2, 1), (3, 1)]] ).
        lda: trained lda model
    Returns:
        pandas dataframe: document by topic NxK matrix
    """
    topics_dist = [
        [
            topic_measure[1]
            for topic_measure in lda.get_document_topics(doc, minimum_probability=0)
        ]
        for doc in corpus
    ]
    df = pd.DataFrame(
        topics_dist,
        columns=[
            "%s_%sK_" % (content_type, lda.num_topics) + str(x)
            for x in range(1, lda.num_topics + 1)
        ],
    )
    return df


def _to_str(x):
    """Convert bytes or other types to string."""
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


def clean_quote_speech_preserve_sentences(text):
    """Takes a string var as argument, process it using regex, and returns a string (all in lowercase).
    Preserves sentence-ending punctuation for readability analysis."""
    pattern1 = "page:\s*?[0-9]+"  # page makers e.g. page: xx
    pattern2 = "[0-9]+[.:]\s*?[0-9]+\s*?pm"  # timestamp e.g. 5.55 pm
    pattern3 = "[0-9]+[.:]\s*?[0-9]+\s*?am"  # timestamp e.g. 11:00 am
    pattern4 = "column:\s*?[0-9]+"  # column makers e.g. column: xxxx
    pattern5 = "\(.+\)"  # remove anything in parentheses
    pattern6 = "\[.+\]"  # remove anything in brackets
    pattern = "|".join((pattern1, pattern2, pattern3, pattern4, pattern5, pattern6))

    if pd.isna(text):
        return np.nan
    try:
        text = re.sub(pattern, "", text.lower())
    except AttributeError:
        pass

    text = re.sub("\s+", " ", text)
    return text


def add_parliament_periods(df, date_col="matched_date", fallback_col="date"):
    """
    Add parliament period indicators to dataframe.

    Parameters:
    -----------
    df : DataFrame
        Input dataframe
    date_col : str
        Name of primary date column
    fallback_col : str
        Name of fallback date column for null values

    Returns:
    --------
    DataFrame with added parliament columns
    """
    # Fill nulls in date column
    df[date_col] = np.where(df[date_col].isnull(), df[fallback_col], df[date_col])

    # Define parliament periods
    parliaments = {
        10: (None, datetime.datetime(2006, 4, 20)),
        11: (datetime.datetime(2006, 11, 2), datetime.datetime(2011, 4, 19)),
        12: (datetime.datetime(2011, 10, 10), datetime.datetime(2015, 8, 25)),
        13: (datetime.datetime(2016, 1, 15), None),
    }

    # Create binary indicators
    for num, (start, end) in parliaments.items():
        if start is None:
            condition = df[date_col] <= end
        elif end is None:
            condition = df[date_col] >= start
        else:
            condition = (df[date_col] >= start) & (df[date_col] <= end)

        df[f"parl{num}"] = np.where(condition, 1, 0)

    # Create categorical variable
    df["parl"] = ""
    for num, (start, end) in parliaments.items():
        if start is None:
            condition = df[date_col] <= end
        elif end is None:
            condition = df[date_col] >= start
        else:
            condition = (df[date_col] >= start) & (df[date_col] <= end)

        df["parl"] = np.where(condition, f"{num}th parliament", df["parl"])

    return df
