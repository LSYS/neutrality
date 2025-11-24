## Results

------
### Main

#### Figure 2

#### Table 3
|              |          (1)    |          (2)    |          (3)    |          (4)    |          (5)    |          (6)    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -1.47**  |        -1.27*   |        -2.34*** |        -1.99*** |        -5.36*** |        -4.39*** |
|              |       (0.70)    |       (0.75)    |       (0.70)    |       (0.64)    |       (1.52)    |       (1.52)    |
| Time fixed-effects |            x    |            x    |            x    |            x    |            x    |            x    |
| Individual controls |            x    |            x    |            x    |            x    |            x    |            x    |
| Article controls |            x    |            x    |            x    |            x    |            x    |            x    |
| Topic controls |            x    |            x    |            x    |            x    |            x    |            x    |
| Ministerial controls |            x    |            x    |            x    |            x    |            x    |            x    |
| Electoral controls |                 |            x    |                 |            x    |                 |            x    |
| *R*<sup>2</sup> |        0.160    |        0.188    |        0.111    |        0.119    |        0.158    |        0.192    |
| F-statistic, time fixed-effects |   4.89^{***}    |   2.87^{***}    |   4.14^{***}    |    2.06^{**}    |   3.36^{***}    |    2.36^{**}    |
| F-statistic, individual controls |    2.07^{**}    |          .79    |    2.03^{**}    |          .74    |         1.66    |      1.7^{*}    |
| F-statistic, topic controls |   2.01^{***}    |   1.91^{***}    |   1.65^{***}    |   1.48^{***}    |   1.89^{***}    |   1.83^{***}    |
| F-statistic, ministerial controls |   3.69^{***}    |   3.01^{***}    |   2.37^{***}    |   1.94^{***}    |    2.9^{***}    |   2.43^{***}    |
| F-statistic, electoral controls |                 |         1.06    |                 |         1.26    |                 |    2.88^{**}    |
| Mean of dependent variable |        91.56    |        91.98    |        96.66    |        96.85    |        89.94    |        90.31    |
| N            | \multicolumn{1}{c}{   14,850}    | \multicolumn{1}{c}{   10,872}    | \multicolumn{1}{c}{   14,850}    | \multicolumn{1}{c}{   10,872}    | \multicolumn{1}{c}{   14,850}    | \multicolumn{1}{c}{   10,872}    |

Standard errors in parentheses<br>
* *p* < 0.1, ** *p* < 0.05, *** *p* < 0.01


#### Figure 3
<table>
  <tr>
    <td width="34%" align="center">
      <img src="./figures/pred-margins-year-ss1_quote_to_speech.png" width="100%"><br>
      <b>(a) Substring</b>
    </td>
    <td width="34%" align="center">
      <img src="./figures/pred-margins-year-ss2_quote_to_speech.png" width="100%"><br>
      <b>(b) BoW</b>
    </td>
    <td width="34%" align="center">
      <img src="./figures/pred-margins-year-ce_max_quote2speech.png" width="100%"><br>
      <b>(c) Semantic</b>
    </td>
  </tr>
</table>

#### Figure 4
![Figure 4](./figures/specchart-acc1.png)

#### Figure 5

------------
### Intensity

#### Figure C2

<table>
  <tr>
    <td width="50%" align="center">
      <img src="./figures/partyyear-count.png" width="100%"><br>
      <b>(a) By year</b>
    </td>
    <td width="50%" align="center">
      <img src="./figures/partyparl-count.png" width="100%"><br>
      <b>(b) By parliament </b>
    </td>
  </tr>
</table>

#### Table C1

|              |          (1)    |          (2)    |
| ------------ | :-------------: | :-------------: |
| Opposition   |         0.05    |         0.04    |
|              |       (0.06)    |       (0.07)    |
| Time fixed-effects |            x    |            x    |
| Individual controls |            x    |            x    |
| Article controls |            x    |            x    |
| Topic controls |            x    |            x    |
| Ministerial controls |            x    |            x    |
| Electoral controls |                 |            x    |
| *N*          |         7072    |         5132    |
| *R*<sup>2</sup> |        0.204    |        0.217    |

Standard errors in parentheses<br>
* *p* < 0.1, ** *p* < 0.05, *** *p* < 0.01

------------
### Sensitivity
#### Table D1

##### Panel A. Substring

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -1.47**  |        -1.92**  |        -1.74*** |        -1.30*   |        -1.47**  |        -1.85**  |        -1.18*   |        -1.50**  |        -1.76**  |        -1.48**  |        -1.45**  |        -1.38**  |
|              |       (0.70)    |       (0.77)    |       (0.55)    |       (0.70)    |       (0.74)    |       (0.81)    |       (0.71)    |       (0.71)    |       (0.69)    |       (0.70)    |       (0.70)    |       (0.69)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

##### Panel B. Substring (no stopwords)

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -1.53**  |        -2.04*** |        -1.73*** |        -1.33*   |        -1.53**  |        -1.96**  |        -1.24*   |        -1.63**  |        -1.83*** |        -1.56**  |        -1.51**  |        -1.46**  |
|              |       (0.71)    |       (0.78)    |       (0.56)    |       (0.70)    |       (0.75)    |       (0.82)    |       (0.72)    |       (0.72)    |       (0.70)    |       (0.70)    |       (0.71)    |       (0.70)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

##### Panel C. BoW

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -2.34*** |        -2.51*** |        -1.98*** |        -2.21*** |        -2.34*** |        -2.42*** |        -2.10*** |        -2.25*** |        -2.57*** |        -2.23*** |        -2.31*** |        -2.33*** |
|              |       (0.70)    |       (0.75)    |       (0.56)    |       (0.70)    |       (0.71)    |       (0.85)    |       (0.72)    |       (0.72)    |       (0.70)    |       (0.69)    |       (0.70)    |       (0.71)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

##### Panel D. BoW (no stopwords)

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -3.07*** |        -3.28*** |        -2.50*** |        -2.93*** |        -3.07*** |        -3.17**  |        -2.69*** |        -2.98*** |        -3.41*** |        -2.98*** |        -3.01*** |        -3.01*** |
|              |       (0.92)    |       (0.99)    |       (0.71)    |       (0.92)    |       (0.93)    |       (1.23)    |       (0.93)    |       (0.94)    |       (0.91)    |       (0.89)    |       (0.91)    |       (0.91)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

##### Panel E. Semantic

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -5.36*** |        -5.07*** |        -5.27*** |        -4.85*** |        -5.36*** |        -4.95*** |        -4.54*** |        -4.98*** |        -6.06*** |        -5.05*** |        -5.38*** |        -5.17*** |
|              |       (1.52)    |       (1.63)    |       (1.17)    |       (1.50)    |       (1.51)    |       (1.90)    |       (1.49)    |       (1.52)    |       (1.49)    |       (1.50)    |       (1.52)    |       (1.45)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

##### Panel F. Semantic (binarized > 99; near perfect sim)

|              | (1) Baseline Regression    | (2) Journalist FE    | (3) No ministerial controls    | (4) No translations    | (5) Cluster by speech    | (6) Cluster by journalist    | (7) Speech K = 50    | (8) Speech K = 100    | (9) Article K = 30    | (10) Article K = 50    | (11) Sentence topics    | (12) Parsimonious topics    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -0.05**  |        -0.04*   |        -0.07*** |        -0.05**  |        -0.05**  |        -0.04    |        -0.04*   |        -0.04**  |        -0.06*** |        -0.04**  |        -0.05**  |        -0.04**  |
|              |       (0.02)    |       (0.02)    |       (0.02)    |       (0.02)    |       (0.02)    |       (0.03)    |       (0.02)    |       (0.02)    |       (0.02)    |       (0.02)    |       (0.02)    |       (0.02)    |
| *N*          |        14850    |        13477    |        14885    |        14645    |        14850    |        13495    |        14850    |        14850    |        14850    |        14850    |        14850    |        14850    |

Standard errors in parentheses<br>
* *p* < 0.1, ** *p* < 0.05, *** *p* < 0.01



#### Figure D1
![Figure D1](./figures/specchart-acc2.png)

#### Figure D2
![Figure D2](./figures/specchart-semantic.png)

------------
#### Table D2

##### Panel A. Substring
|              | (1) Baseline    | (2) +Objectivity    | (3) +Polarity    | (4) +Readability    | (5) +Lexical    |     (6) +All    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -1.47**  |        -1.47**  |        -1.49**  |        -1.65**  |        -1.30*   |        -1.50**  |
|              |       (0.70)    |       (0.70)    |       (0.70)    |       (0.71)    |       (0.71)    |       (0.71)    |
| Objectivity of speech and quote |                 |         0.01    |                 |                 |                 |        -0.00    |
|              |                 |       (0.06)    |                 |                 |                 |       (0.07)    |
| Polarity of speech and quote |                 |                 |        -0.06    |                 |                 |        -0.04    |
|              |                 |                 |       (0.06)    |                 |                 |       (0.06)    |
| Grade/readability score of speech transcipt |                 |                 |                 |         0.40*** |                 |         0.37*** |
|              |                 |                 |                 |       (0.09)    |                 |       (0.09)    |
| Lexical richness of speech transcipt |                 |                 |                 |                 |         0.50*** |         0.47*** |
|              |                 |                 |                 |                 |       (0.07)    |       (0.08)    |
| *N*          |        14850    |        14850    |        14850    |        14839    |        14797    |        14787    |

##### Panel B. BoW

|              | (1) Baseline    | (2) +Objectivity    | (3) +Polarity    | (4) +Readability    | (5) +Lexical    |     (6) +All    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -2.34*** |        -2.30*** |        -2.33*** |        -2.37*** |        -2.29*** |        -2.26*** |
|              |       (0.70)    |       (0.70)    |       (0.70)    |       (0.70)    |       (0.70)    |       (0.70)    |
| Objectivity of speech and quote |                 |        -0.11**  |                 |                 |                 |        -0.11**  |
|              |                 |       (0.05)    |                 |                 |                 |       (0.05)    |
| Polarity of speech and quote |                 |                 |         0.04    |                 |                 |         0.01    |
|              |                 |                 |       (0.05)    |                 |                 |       (0.05)    |
| Grade/readability score of speech transcipt |                 |                 |                 |         0.05    |                 |         0.02    |
|              |                 |                 |                 |       (0.08)    |                 |       (0.08)    |
| Lexical richness of speech transcipt |                 |                 |                 |                 |         0.22*** |         0.22*** |
|              |                 |                 |                 |                 |       (0.08)    |       (0.08)    |
| *N*          |        14850    |        14850    |        14850    |        14839    |        14797    |        14787    |


##### Panel C. Semantic
|              | (1) Baseline    | (2) +Objectivity    | (3) +Polarity    | (4) +Readability    | (5) +Lexical    |     (6) +All    |
| ------------ | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Opposition   |        -5.36*** |        -5.22*** |        -5.33*** |        -5.12*** |        -5.17*** |        -4.69*** |
|              |       (1.52)    |       (1.52)    |       (1.51)    |       (1.51)    |       (1.52)    |       (1.51)    |
| Objectivity of speech and quote |                 |        -0.38*** |                 |                 |                 |        -0.37*** |
|              |                 |       (0.13)    |                 |                 |                 |       (0.14)    |
| Polarity of speech and quote |                 |                 |         0.14    |                 |                 |         0.04    |
|              |                 |                 |       (0.13)    |                 |                 |       (0.13)    |
| Grade/readability score of speech transcipt |                 |                 |                 |        -0.64*** |                 |        -0.71*** |
|              |                 |                 |                 |       (0.17)    |                 |       (0.18)    |
| Lexical richness of speech transcipt |                 |                 |                 |                 |         0.52*** |         0.57*** |
|              |                 |                 |                 |                 |       (0.15)    |       (0.15)    |
| *N*          |        14850    |        14850    |        14850    |        14839    |        14797    |        14787    |

Standard errors in parentheses<br>
* *p* < 0.1, ** *p* < 0.05, *** *p* < 0.01

