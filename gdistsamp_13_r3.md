
```r
# predictions from GDistsamp 2013 Round 3
setwd("~/Documents/data")
library(unmarked)
```

```
## Loading required package: methods
## Loading required package: reshape
```

```
## Warning: package 'reshape' was built under R version 3.1.2
```

```
## Loading required package: lattice
## Loading required package: Rcpp
```

```r
#read in the sora observations
sora13r3 <- read.csv('2013r3_sora.csv', header=T)
#read in the covariate data #organized by impoundment.
cov13r3 <- read.csv('2013r3_cov.csv', header=T)
#subset covaraites we need
cov13r3 <- cov13r3[,c("region","length_3","impound","jdate_3","hectares","area", "int","short","water")]
# #the distance bins

sora13r3 <- sora13r3[order(sora13r3$impound),]
cov13r3 <- cov13r3[order(cov13r3$impound),]

sora13r3 <- sora13r3[,2:40]
cutpt = as.numeric(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13)) 
#Unmarked Data Frame
umf13r3 = unmarkedFrameGDS(y=sora13r3, 
                           numPrimary=3,
                           siteCovs = cov13r3,
                           survey="line", 
                           dist.breaks=cutpt,  
                           unitsIn="m", 
                           tlength=cov13r3$length_3,
)
```


```r
model13r3 <- list()
model13r3$null13r3 = gdistsamp(lambdaformula = ~1, 
                     phiformula = ~1, 
                     pformula = ~1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")

model13r3$reg13r3 = gdistsamp(lambdaformula = ~region-1, 
                    phiformula = ~1, 
                    pformula = ~ 1,
                    data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
```

```r
model13r3$reg_w13r3 =gdistsamp(lambdaformula = ~region+water-1, 
                     phiformula = ~1, 
                     pformula = ~ 1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")

model13r3$reg_w_i_13r3 =gdistsamp(lambdaformula = ~region+water+region*water-1, 
                     phiformula = ~1, 
                     pformula = ~ 1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
```

```r
model13r3$short_r13r3 =gdistsamp(lambdaformula = ~short+region-1, 
                     phiformula = ~1, 
                     pformula = ~ 1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
model13r3$short_r_i_13r3 =gdistsamp(lambdaformula = ~short+region+short*region-1, 
                     phiformula = ~1, 
                     pformula = ~ 1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
```

```r
model13r3$short13r3 =gdistsamp(lambdaformula = ~short-1, 
                     phiformula = ~1, 
                     pformula = ~ 1,
                     data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")

model13r3$short_w13r3 =gdistsamp(lambdaformula = ~short+water-1, 
                       phiformula = ~1, 
                       pformula = ~ 1,
                       data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
model13r3$short_w_i_13r3 =gdistsamp(lambdaformula = ~short+water+short*water-1, 
                       phiformula = ~1, 
                       pformula = ~ 1,
                       data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
```

```r
model13r3$global13r3 =gdistsamp(lambdaformula = ~region+water+short+region*water+water*short+region*short+region*water*short-1, 
                      phiformula = ~1, 
                      pformula = ~ 1,
                      data = umf13r3, keyfun = "hazard", mixture="P",se = T, output="abund")
```

```r
list13r3  = fitList(model13r3)
```

```
## Warning: If supplying a list of fits, use fits = 'mylist'
```

```r
model13r3 = modSel(list13r3)
model13r3
```

```
##                nPars     AIC   delta    AICwt cumltvWt
## global13r3        19 -369.56    0.00  1.0e+00     1.00
## reg_w_i_13r3      11 -195.24  174.31  1.4e-38     1.00
## short_r_i_13r3    11 -101.34  268.22  5.7e-59     1.00
## reg_w13r3          8  -40.23  329.33  3.1e-72     1.00
## short_r13r3        8  -33.56  336.00  1.1e-73     1.00
## reg13r3            7  -30.07  339.49  1.9e-74     1.00
## null13r3           4  307.37  676.92 1.0e-147     1.00
## short_w_i_13r3     6  716.62 1086.17 1.4e-236     1.00
## short_w13r3        5  770.54 1140.10 2.7e-248     1.00
## short13r3          4  908.60 1278.16 2.8e-278     1.00
```