Exercise 03 - Basic Fire Weather Analyses
================

Objectives
==========

-   Download two weather data sets
-   Graph distributions of data
-   Complete a statistical test on our data
-   Complete an anova

Turning on the libraries we will need:
--------------------------------------

Let's turn on `ggplot2`, `cowplot`, `riem`, and `lubridate`

``` r
library("ggplot2")
library("lubridate")
library("cowplot")
library("riem")
```

Downloading Weather Data
------------------------

Let's download weather data from two weather stations, one in Cortez, CO and one in Fort Collins.

``` r
FCO_2018 <- riem_measures("FNL", date_start = "2018-01-01", date_end = "2018-12-31")
CEZ_2018 <- riem_measures("CEZ", date_start = "2018-01-01", date_end = "2018-12-31")
```

Let's plot the distribution of the temperatures. First, we'll need to fix the timezones (as before).

``` r
FCO_2018$DateTime <- with_tz(FCO_2018$valid, "MST")
CEZ_2018$DateTime <- with_tz(CEZ_2018$valid, "MST")
```

Okay, let's plot the distribution of temperatures across the year:

Let's use a new geom, geom\_density, which displays a smooth histogram.

``` r
tempPlotDensity <- ggplot()+
  geom_density(data = FCO_2018, fill = "green", aes(x = tmpf))+
  geom_density(data = CEZ_2018, fill = "gray50", aes(x = tmpf))+
  theme_cowplot()
tempPlotDensity
```

![](03_FireWeather_Analyses_files/figure-markdown_github/density1-1.png)

That's a bit tough to read though, isn't it? Let's change the transparency using the "alpha" argument.

``` r
tempPlotDensity <- ggplot()+
  geom_density(data = FCO_2018, fill = "green", alpha = .5, aes(x = tmpf))+
  geom_density(data = CEZ_2018, fill = "gray50", alpha = .5, aes(x = tmpf))+
  theme_cowplot()
tempPlotDensity
```

    ## Warning: Removed 100801 rows containing non-finite values (stat_density).

    ## Warning: Removed 103497 rows containing non-finite values (stat_density).

![](03_FireWeather_Analyses_files/figure-markdown_github/density2-1.png)

Much better.

Let's look at it as boxplots.

``` r
tempPlotBox <- ggplot()+
  coord_flip()+
  geom_boxplot(data = FCO_2018, aes(x= "Fort Collins", y = tmpf))+
  geom_boxplot(data = CEZ_2018, aes(x = "Cortez", y = tmpf))+
  theme_cowplot()
tempPlotBox
```

    ## Warning: Removed 100801 rows containing non-finite values (stat_boxplot).

    ## Warning: Removed 103497 rows containing non-finite values (stat_boxplot).

![](03_FireWeather_Analyses_files/figure-markdown_github/boxplot1-1.png)

You'll see we did two new things there:

1.  We flipped the axes with "coord\_flip"

2.  Instead of mapping the x axes to variables, we mapped them to static values "Fort Collins" and "Cortez"

### Plotting Months

Let's add a new column and use the `lubridate` command `month` to identify the months of each date.

``` r
CEZ_2018$Month <- month(CEZ_2018$DateTime, label = TRUE)
FCO_2018$Month <- month(FCO_2018$DateTime, label = TRUE)
```

Now let's subset to JUST the July values. We'll use the `subset` function and assign the output to two new dataframes:

``` r
CEZ_2018July <- subset(CEZ_2018, Month == "Jul")
FCO_2018July <- subset(FCO_2018, Month == "Jul")
```

And plot it, including `geom_jitter`:

``` r
tempMonthPlot <- ggplot()+
  coord_flip()+
  geom_boxplot(data = FCO_2018July, fill = "red", aes(x = "Fort Collins", y = tmpf))+
  geom_boxplot(data = CEZ_2018July, fill = "blue", aes(x = "Cortez", y = tmpf))+
    geom_jitter(data = FCO_2018July, fill = "red", aes(x = "Fort Collins", y = tmpf))+
  geom_jitter(data = CEZ_2018July, fill = "blue", aes(x = "Cortez", y = tmpf))+
  theme_cowplot()
tempMonthPlot
```

    ## Warning: Removed 8745 rows containing non-finite values (stat_boxplot).

    ## Warning: Removed 8886 rows containing non-finite values (stat_boxplot).

    ## Warning: Removed 8745 rows containing missing values (geom_point).

    ## Warning: Removed 8886 rows containing missing values (geom_point).

![](03_FireWeather_Analyses_files/figure-markdown_github/boxplot2-1.png)

Nice! You may notice some changes in relative size in the plot. If you zoom in on it, these may change.

Let's compare it to just the July density plots:

``` r
tempMonthPlotDensity <- ggplot()+
  geom_density(data = FCO_2018July, fill = "green", alpha = .5, aes(x = tmpf))+
  geom_density(data = CEZ_2018July, fill = "gray50", alpha = .5, aes(x = tmpf))+
  theme_cowplot()
tempMonthPlotDensity
```

    ## Warning: Removed 8745 rows containing non-finite values (stat_density).

    ## Warning: Removed 8886 rows containing non-finite values (stat_density).

![](03_FireWeather_Analyses_files/figure-markdown_github/density3-1.png)

Density plots can highlight differences in distributions that hard hard to see in boxplots or jittered points.

### Challenge

-   Create two dataframes that have February weather for Cortez and Fort Collins.
-   Plot the distributions using geom\_density of February weather. Change the transparency to .75 and the colors to black and red.

Analyses
--------

### T-Test

We'd like to perform a statistical test on the July temperature data. They look pretty similar.

-   What is our hypothesis?

-   What is our test?

The correct test here might be the Welch's two-sampled t-test, that does not assume equal variances between samples. This is always a safe starting assumption.

Let's do it:

``` r
t.test(FCO_2018July$tmpf, CEZ_2018July$tmpf, 
       alternative = "two.sided", 
       var.equal = FALSE)
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  FCO_2018July$tmpf and CEZ_2018July$tmpf
    ## t = -3.5001, df = 1706.6, p-value = 0.0004771
    ## alternative hypothesis: true difference in means is not equal to 0
    ## 95 percent confidence interval:
    ##  -2.9699056 -0.8367409
    ## sample estimates:
    ## mean of x mean of y 
    ##  72.91712  74.82045

Interesting. How would we report these results?

### Linear Model

Great! Let's plot just the temperature and relative humidity from July in Cortez:

``` r
windWxPlot <- ggplot(data = CEZ_2018July, aes(x = tmpf, y = relh))+
  geom_point()
windWxPlot
```

    ## Warning: Removed 8902 rows containing missing values (geom_point).

![](03_FireWeather_Analyses_files/figure-markdown_github/plotWx-1.png)

Looking good. Now let's fit a linear model to these data:

``` r
tempRH <- lm(data = CEZ_2018July, formula = relh~tmpf)
summary(tempRH)
```

    ## 
    ## Call:
    ## lm(formula = relh ~ tmpf, data = CEZ_2018July)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -40.031  -5.410   1.335   7.164  30.562 
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 145.95846    2.69037   54.25   <2e-16 ***
    ## tmpf         -1.36937    0.03561  -38.46   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 12.02 on 833 degrees of freedom
    ##   (8902 observations deleted due to missingness)
    ## Multiple R-squared:  0.6397, Adjusted R-squared:  0.6393 
    ## F-statistic:  1479 on 1 and 833 DF,  p-value: < 2.2e-16

`ggplot2` can also display some models using geom\_smooth with method="lm". It will default to y~x as a format, which is what we used.

``` r
tmpfrelhPlot <- ggplot(data = CEZ_2018July, aes(x = tmpf, y = relh))+
  geom_point()+
  geom_smooth(method = "lm")
tmpfrelhPlot
```

    ## Warning: Removed 8902 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 8902 rows containing missing values (geom_point).

![](03_FireWeather_Analyses_files/figure-markdown_github/plotWx_model-1.png)

### Challenge

-   Subset the Fort Collins and Cortez data to just January
-   Complete a two-sampled t-test on the January temperature data for Fort Collins and Cortez
-   Plot the relationship between temperature and windspeed (sknt) in Fort Collins in 2018
-   Fit a linear model to the relationship of temperature and relative humidity in Fort Collins in January
