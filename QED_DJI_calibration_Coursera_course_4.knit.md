---
title: "<img src='figure/coursera.jpg' width='37'> <img src='figure/nyu.png' width='240'>"
subtitle: "<span style='color:white; background-color:#4E79A7;'>Overview of Advanced Methods of Reinforcement Learning in Finance</span> (An R Markdown document converted from './data/QED_DJI_calibration_Coursera_course_4.ipynb')"
author: "[®γσ, Lian Hu](https://englianhu.github.io/) <img src='figure/quantitative trader 1.jpg' width='12'> <img src='figure/ENG.jpg' width='24'> ®"
date: "2021-05-14"
output:
  html_document: 
    mathjax: https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
    number_sections: yes
    toc: yes
    toc_depth: 4
    toc_float:
      collapsed: yes
      smooth_scroll: yes
    code_folding: hide
    css: CSSBackgrounds.css
---

<br>
<span style='color:green'>**Theme Song**</span>
<br>

<audio src="music/NY-BJ-Dream.mp3" controls></audio>
<br>

------

## SCSS Setup

<style>
pre {
  overflow-x: auto;
}
pre code {
  word-wrap: normal;
  white-space: pre;
}
</style>


```{.r .bg-success}
# install.packages("remotes")
require('BBmisc')
#remotes::install_github("rstudio/sass")
lib('sass')
```

```{.bg-primary}
## sass 
## TRUE
```


```{.scss .bg-success}
/* https://stackoverflow.com/a/66029010/3806250 */
h1 { color: #002C54; }
h2 { color: #2F496E; }
h3 { color: #375E97; }

/* ----------------------------------------------------------------- */
/* https://gist.github.com/himynameisdave/c7a7ed14500d29e58149#file-broken-gradient-animation-less */
.hover-animate-background1 {
  /* color: #FFD64D; */
  background: linear-gradient(155deg, #EDAE01 0%, #FFEB94 100%);
  transition: all 0.45s;
  &:hover{
    background: linear-gradient(155deg, #EDAE01 20%, #FFEB94 80%);
    }
  }

/* //  For brevity, vendor prefixes have been removed. */
/* //  This does not work as expected; instead of a smooth transition */
/* //  what you get is a hard swap from one gradient to the next */
.hover-animate-background2 {
  color: #FFD64D;
  background: linear-gradient(155deg, #002C54 0%, #4CB5F5 100%);
  transition: all 0.45s;
  &:hover{
    background: linear-gradient(155deg, #002C54 20%, #4CB5F5 80%);
    }
  }
```


<style type="text/css">
h1{color:#002C54}h2{color:#2F496E}h3{color:#375E97}.hover-animate-background1{background:linear-gradient(155deg, #EDAE01 0%, #FFEB94 100%);transition:all 0.45s}.hover-animate-background1:hover{background:linear-gradient(155deg, #EDAE01 20%, #FFEB94 80%)}.hover-animate-background2{color:#FFD64D;background:linear-gradient(155deg, #002C54 0%, #4CB5F5 100%);transition:all 0.45s}.hover-animate-background2:hover{background:linear-gradient(155deg, #002C54 20%, #4CB5F5 80%)}
</style>


```{.r .bg-success}
## https://stackoverflow.com/a/36846793/3806250
options(width = 999)
knitr::opts_chunk$set(class.source = 'hover-animate-background1', class.output = 'hover-animate-background2', class.error = 'bg-danger')
```

<br><br>

------

## Econometric estimation of an IRL-based market portfolio model. Part II: QED

Welcome to your final course project on Advanced Topic RL in Finance. In this project you will: 

- Explore and estimate an IRL-based model of market returns (the `"QED"` model) that is obtained by a generalization of a model that you analyzed in the previous course
- Respectively, you are expected to re-utilize parts of your previous code from the course project from Course 3: RL (but you can also start from scratch - the template provided here is nearly identical to the one offered to you in course 3)
- Investige the role of non-linearities in price dynamics
- Investigate the role and impact of choices of different signals on model estimation and trading strategies

<br>

**Instructions for project structure and grading principles :**

- This is a project that will be graded based on a peer-to-peer review. The project consists of four parts. The maximum score for each part is 10, so that maximum score you can give your peers (and they can give you) is 40. The parts are as follows (more detailed instructions are in specific cells below):

- **Part 1**: Estimate the model using the DJI portfolio of 30 stocks, first without signals, and then using simple signals such as simple moving averages constructed below (Max 10 point).

- **Part 2**: Explore the implications of calibrated model parameters for default probabilities of stocks in your portfolio. Present your conclusions and observations. (Max 10 point).

- **Part 3**: Experiment with other signals and investigate the impact on model calibration obtained with alternative signals. Present your conclusions and observations. (Max 10 points).

- **Part 4** : Show me something else. This part is optional. Come up with your own idea of an interesting analysis.
For example, you can repeat your analysis for the S&P portfolio.
Or maybe you can build a strategy using an optimal market-implied policy estimated from this model, and compare it with PCA and absorption ratio strategies that we built in Course 2. Or anything else.  (Max 10 points).

<br>

**Instructions for formatting your notebook and packages use can use **

- Use one or more cells of the notebook for each section of the project. Each section is marked by a header cell below. Insert your cells between them without changing the sequence. 

- Think of an optimal presentation of your results and conclusions. Think of how hard or easy it will be for your fellow students to follow your logic and presentation. When you are grading others, you can add or subtract point for the quality of presentation.

- You will be using Python 3 in this project. Using **TensorFlow** is encouraged but is not strictly necessary, you can use optimization algorithms available in `scipy` or `scikit-learn` packages. If you use any non-standard packages, you should state all neccessary additional imports (or instructions how to install any additional modules you use in a top cell of your notebook. If you create a new portfolio for parts 3 and 4 in the project, make your code for creating your dataset replicable as well, so that your grader can reproduce your code locally on his/her machine.   

- Try to write a clean code that can be followed by your peer reviewer. When you are the reviewer, you can add or subtract point for the quality of code. 

<br>

**After completing this project you will:**

- Get experience with building and estimation of your second IRL based model of market dynamics.
- Develop intuition and understanding about the role of non-linearities in dynamics model. 
- Develop intuition on whether the same model could be calibrated to both equity and credit data.
- Be able to implement trading strategies based on this method.

Let's get started!

## The "Quantum Equlibrium-Disequlibrium" (QED) IRL-based model of stock returns

In Week 3 lectures of our course we presented the "QED" model

$$
d X_t = \kappa X_t  \left( \frac{\theta}{\kappa} - X_t - \frac{g}{\kappa} X_t^2 \right) dt +  \\
X_t \left( {\bf w} {\bf z}_t \, dt + \sigma d W_t \right)
$$

In this project, you will explore calibration of this model to market data.
As in the course project for course 3 you analyzed the same model in the limit $g = 0$, you would be able to re-utilize parts of your previous code in this project).


```{.python .hover-animate-background1}
#pip3 install pandas numpy tensorflow matplotlib datetime
import pandas as pd
import numpy as np
import tensorflow as tf

import matplotlib.pyplot as plt
from datetime import datetime
```


```{.python .hover-animate-background1}
# read the data to a Dataframe
df_cap = pd.read_csv('./data/dja_cap.csv')
```


```{.python .hover-animate-background1}
# add dates
dates = pd.bdate_range(start = '2010-01-04', end = None, periods = df_cap.shape[0], freq = 'B')
df_cap['date'] = dates

df_cap.set_index('date', inplace = True)
df_cap.head()
```

```{.hover-animate-background2}
##                     AAPL          AXP  ...           WMT           XOM
## date                                   ...                            
## 2010-01-04  1.937537e+11  48660795480  ...  206625627560  3.272107e+11
## 2010-01-05  1.940887e+11  48553770270  ...  204568134680  3.284884e+11
## 2010-01-06  1.910015e+11  49338621810  ...  204110914040  3.313275e+11
## 2010-01-07  1.906484e+11  49921314620  ...  204225219200  3.302865e+11
## 2010-01-08  1.919159e+11  49885639550  ...  203196472760  3.289615e+11
## 
## [5 rows x 30 columns]
```

## Let us build some signals 

Here we provide a "warm start" by computing two simple moving average signals that you can use as benchmark in your analysis.

### Generate moving averages


```{.python .hover-animate-background1}
# Calculating the short-window (10 days) simple moving average

window_1 = 10

short_rolling = df_cap.rolling(window=window_1).mean()
# short_rolling.head(20)
```


```{.python .hover-animate-background1}
# Calculating the long-window (30 days) simple moving average

window_2 = 30
long_rolling = df_cap.rolling(window=window_2).mean()
# long_rolling.tail()
```

### Plot three years of AAPL stock:


```{.python .hover-animate-background1}
ticker = 'AAPL'
start_date = '2015-01-01'
end_date = '2017-12-31'

fig = plt.figure(figsize=(10,6))
ax = fig.add_subplot(1,1,1)

ax.plot(df_cap.loc[start_date:end_date, :].index, df_cap.loc[start_date:end_date, 'AAPL'], label='Cap')
```

```{.hover-animate-background2}
## [<matplotlib.lines.Line2D object at 0x7f0c3c9495b0>]
```

```{.python .hover-animate-background1}
ax.plot(long_rolling.loc[start_date:end_date, :].index, long_rolling.loc[start_date:end_date, 'AAPL'], 
          label = '%d-days SMA' % window_2)
```

```{.hover-animate-background2}
## [<matplotlib.lines.Line2D object at 0x7f0c3c90b4c0>]
```

```{.python .hover-animate-background1}
ax.plot(short_rolling.loc[start_date:end_date, :].index, short_rolling.loc[start_date:end_date, 'AAPL'], 
         label = '%d-days SMA' % window_1)
```

```{.hover-animate-background2}
## [<matplotlib.lines.Line2D object at 0x7f0c3c90ba00>]
```

```{.python .hover-animate-background1}
ax.legend(loc='best')
```

```{.hover-animate-background2}
## <matplotlib.legend.Legend object at 0x7f0c3c90b310>
```

```{.python .hover-animate-background1}
ax.set_ylabel('Cap in $')
```

```{.hover-animate-background2}
## Text(0, 0.5, 'Cap in $')
```

```{.python .hover-animate-background1}
plt.show()
```

<img src="QED_DJI_calibration_Coursera_course_4_files/figure-html/unnamed-chunk-6-1.png" width="960" />

## Part 1: Model calibration with or without moving average signals (Max 10 points)

To calibrate the model, it is convenient to use the log-prices instead of prices. Diffusion in the log-space 
$ y = \log x $ is given by the following Langevin equation:

$$
d y_t = - \frac{ \partial V(y)}{\partial y} dt + \sigma dW_t , \; \; \;  V(y)  \equiv - \left( \theta - \frac{\sigma^2}{2} + {\bf w} {\bf z}_t \right) y  + \kappa e^y + \frac{1}{2} g e^{2y}
$$

where $ W_t $ is a standard Brownian motion.
In terms of variables $ y = \log x $, the negative log-likelihood of data is therefore

$$
LL_M (\Theta) = - \log \prod_{t=0}^{T-1} 
\frac{1}{ \sqrt{ 2 \pi  \sigma^2}  } 
\exp \left\{  - \frac{1}{2 \sigma^2} \left(   \frac{ y_{t+ \Delta t} -   y_{t}}{ \Delta t} +  \frac{ \partial V(y)}{\partial y}   
\right)^2
\right\} , 
$$ 

where $ {\bf y}_t  = \log x_t $  now stands for observed values of log-cap. Note that because the model is Markov, the product over $ t = 0, \ldots, T-1 $ does not 
necessarily mean a product of transitions along the same trajectory. The negative log-likelihood should be minimized to estimate parameters $ 
\theta $, $ \sigma $, $ \kappa $, $ g $ and  $ {\bf w} $. You can try to estimate the model first without signals, then with signals.


```{.python .hover-animate-background1}
# Put the rest of you code and analysis for Part I here 
```

## Part 2: Analysis of default rates  (Max 10 point)

For a particle in a potential $ V(y) $ with a metastable minimum $ y = a $ and a barrier with a peak located at $ y = b $, the famous Kramers' escape formula gives the following expression for the escape rate $ r $ (see e.g. the book by van Kampen):

$$ 
r = \frac{\sqrt{ V''(a) \left| V''(b) \right| }}{2 \pi} \exp \left[ - \frac{2}{\sigma^2} (V(b) - V(a) ) \right]
$$

Here $ V''(a) $ and $ V''(b) $ stand for the second derivatives of the potential $ V(y) $ at the minimum and the maximum, respectively. This formula applies as long as the barrier height $ \Delta E \equiv  (V(b) - V(a) \gg \frac{\sigma^2}{2} $. 

Apply the Kramers formula to the QED potential and parameters that you found in your calibration. What range of values of $ r $ do you obtain? Do these values make sense to you? Can you think how you could use the Kramers relation as a way to regularize your MLE calibration?


```{.python .hover-animate-background1}
# Put the rest of your code and analysis for Part 2 here.
```

## Part 3: Propose and analyse your own signals  (Max 10 points)

In this part, you will experiment with other signals. Propose a signal and explain why it is interesting to 
include this signal in the portfolio analysis. Then add your favorite signal or signals to the previous benchmarck signals (or alternatively you can replace them), and repeat the analysis of model calibration. State your conclusions.


```{.python .hover-animate-background1}
# Put the rest of your code and analysis for Part 3 here.
```

## Part 4 (Optional): Show me something else (Max 10 points).

Here you can develop any additional analysis of the model that you may find interesting (One possible suggestion is 
presented above, but you should feel free to choose your own topic). Present your case and finding/conclusions.


```{.python .hover-animate-background1}
# Put the rest of your code and analysis for Part 3 here.
```

