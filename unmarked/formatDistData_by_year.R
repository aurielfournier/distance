########
# This code creates the input files (both veg and bird related) for input into gdistsamp
# This code specifically stacks all of the surveys from one year into one input file
####


###
# Needed Packages ----------------------------------------------------------------------------------------
###
library(unmarked)


####
# Functions ----------------------------------------------------------------------------------------
####

formatDistData <- function (distData, distCol, transectNameCol, dist.breaks, occasionCol,effortMatrix) 
{
  if (!is.numeric(distData[, distCol])) 
    stop("The distances must be numeric")
  transects <- distData[, transectNameCol]
  if (!is.factor(transects)) {
    transects <- as.factor(transects)
    warning("The transects were converted to a factor")
  }
  if (missing(occasionCol)) {
    T <- 1
    occasions <- factor(rep(1, nrow(distData)))
  }
  else {
    occasions <- distData[, occasionCol]
    if (!is.factor(occasions)) {
      occasions <- as.factor(occasions)
      warning("The occasions were converted to a factor")
    }
    T <- nlevels(occasions)
  }
  M <- nlevels(transects)
  J <- length(dist.breaks) - 1
  dist.classes <- levels(cut(distData[, distCol], dist.breaks, 
                             include.lowest = TRUE))
  ya <- array(NA, c(M, J, T), dimnames = list(levels(transects), 
                                              dist.classes, paste("rep", 1:T, sep = "")))
  transect.levels <- levels(transects)
  occasion.levels <- levels(occasions)
  for (i in 1:M) {
    for (t in 1:T) {
      sub <- distData[transects == transect.levels[i] & 
                        occasions == occasion.levels[t], , drop = FALSE]
      ya[i, , t] <- table(cut(sub[, distCol], dist.breaks, 
                              include.lowest = TRUE))
    }
  }
  y <- matrix(ya, nrow = M, ncol = J * T)
  ee <- array(NA, c(M,length(occasion.levels)*(length(dist.breaks)-1)))
  for(i in 1:length(occasion.levels)){
    ee[,((ncol(ee)/length(occasion.levels)*(i-1)+1):(ncol(ee)/length(occasion.levels)*i))] <- matrix(rep(effortMatrix[,i], times=length(dist.breaks)-1), ncol=length(dist.breaks)-1)
  }
  ee[ee==0] <- NA
  y <- y * ee
  dn <- dimnames(ya)
  rownames(y) <- dn[[1]]
  if (T == 1) 
    colnames(y) <- dn[[2]]
  else colnames(y) <- paste(rep(dn[[2]], times = T), rep(1:T, each = J), sep = "")
  return(y)
}


#####--------------------------- ----------------------------------------------------------------------------------------


dist.breaks <- c(0,1,2,3,4,5) 

#birds <- read.csv("C:/Users/avanderlaar/Documents/GitHub/data/all_birds.csv",header=T) 
birds <- read.csv("C:/Users/avand/Documents/data/all_birds.csv",header=T) 
birds <- birds[birds$species=="sora"|birds$species=="s",]
birds <- birds[birds$distance<=5,] # removing the few detections we have that are over 5 meters away from the line
birds <- birds[!is.na(birds$round),]
birds <- birds[!is.na(birds$distance),]

birds$jdate <- as.factor(birds$odate)
birds$night <- as.factor(birds$night)
birds <- birds[!(birds$night==4.2|birds$night==4.1),]

birds$ir <- paste0(birds$impound,"_",birds$round)

birds12 <- birds[birds$year==2012,]
birds12$night <- factor(birds12$night, levels=c(1,2,3))

birds13 <- birds[birds$year==2013,]
birds13$night <- factor(birds13$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))

birds14 <- birds[birds$year==2014,]
birds14$night2 <- NA
birds14$night2 <- factor(birds14$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))

birds14[birds14$night2==1.1|birds14$night2==2.1|birds14$night2==3.1,]$night <- 1
birds14[birds14$night2==1.2|birds14$night2==2.2|birds14$night2==3.2,]$night <- 2
birds14$night <- factor(birds14$night, labels=c(1,2))

birds15 <- birds[birds$year==2015,]
birds15[birds15$impound=="sanctuarysouth",]$impound <- "sanctuary"
birds15[birds15$impound=="sanctuarynorth",]$impound <- "sanctuary"
birds15$night2 <- NA
birds15$night2 <- factor(birds15$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))
birds15[birds15$night2==1.1|birds15$night2==2.1|birds15$night2==3.1,]$night <- 1
birds15[birds15$night2==1.2|birds15$night2==2.2|birds15$night2==3.2,]$night <- 2
birds15$night <- factor(birds15$night, labels=c(1,2))

############################ ----------------------------------------------------------------------------------------

surv <- read.csv("C:/Users/avand/Documents/data/all_surveys.csv",header=T)
surv$num <- 1
surv$ir <- paste0(surv$impound,"_",surv$round)

surv12 <- cast(data=surv[surv$year==2012,], ir ~ night, value="num")

surv13 <- surv[surv$year==2013,]
surv13$night2 <- factor(surv13$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))
surv13 <- surv13[surv13$night2==1.1|surv13$night2==2.1|surv13$night2==3.1|surv13$night2==1.2|surv13$night2==2.2|surv13$night2==3.2,]
surv13 <- surv13[!is.na(surv13$round),]
surv13 <- cast(data=surv13, ir ~ night, value="num")

surv14 <- surv[surv$year==2014,]
surv14$night2 <- factor(surv14$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))
surv14 <- surv14[surv14$night2==1.1|surv14$night2==2.1|surv14$night2==3.1|surv14$night2==1.2|surv14$night2==2.2|surv14$night2==3.2,]
surv14 <- surv14[!is.na(surv14$round),]
surv14[surv14$night2==1.1|surv14$night2==2.1|surv14$night2==3.1,]$night <- 1
surv14[surv14$night2==1.2|surv14$night2==2.2|surv14$night2==3.2,]$night <- 2
surv14$night <- factor(surv14$night, levels=c(1,2))
surv14 <- cast(data=surv14, ir ~ night, value="num")

surv15 <- surv[surv$year==2015,]
surv15$night2 <- factor(surv15$night, levels=c(1.1,1.2,2.1,2.2,3.1,3.2))
surv15 <- surv15[surv15$night2==1.1|surv15$night2==2.1|surv15$night2==3.1|surv15$night2==1.2|surv15$night2==2.2|surv15$night2==3.2,]
surv15 <- surv15[!is.na(surv15$round),]
surv15[surv15$night2==1.1|surv15$night2==2.1|surv15$night2==3.1,]$night <- 1
surv15[surv15$night2==1.2|surv15$night2==2.2|surv15$night2==3.2,]$night <- 2
surv15$night <- factor(surv15$night, levels=c(1,2))
surv15 <- cast(data=surv15, ir ~ night, value="num")

########################## ----------------------------------------------------------------------------------------

birds12 <- birds12[birds12$ir %in% surv12$ir,]
surv12 <- surv12[surv12$ir %in% birds12$ir,]
surv12 <- surv12[,2:4]
surv12[surv12>=1] <- 1
gd2012 <- as.data.frame(formatDistData(birds12, "distance","ir",dist.breaks,"night",surv12))
gd2012$ir <- rownames(gd2012)
gd2012$year <- 2012

birds13 <- birds13[birds13$ir %in% surv13$ir,]
surv13 <- surv13[surv13$ir %in% birds13$ir,]
surv13 <- surv13[,2:7]
surv13[surv13>=1] <- 1
gd2013 <- as.data.frame(formatDistData(birds13, "distance","ir",dist.breaks,"night",surv13))
gd2013$ir <- rownames(gd2013)
gd2013$year <- 2013

newdf <- as.data.frame(matrix(ncol=30, nrow=nrow(gd2013)))

for(i in 1:nrow(gd2013)){
  row <- gd2013[i,1:30]
  newdf[i,1:length(row[!is.na(row)])] <- row[!is.na(row)]
}


newnewdf <- cbind(newdf[,1:10], gd2013[,31:32])

gd2013 <- newnewdf[!is.na(newnewdf$V6),]



birds14 <- birds14[birds14$ir %in% surv14$ir,]
surv14 <- surv14[surv14$ir %in% birds14$ir,]
surv14 <- surv14[,2:3]
surv14[surv14>=1] <- 1
gd2014 <- as.data.frame(formatDistData(birds14, "distance","ir",dist.breaks,"night",surv14))
gd2014$ir <- rownames(gd2014)
gd2014$year <- 2014

gd2014 <- gd2014[!is.na(gd2014$`[0,1]2`),]
gd2014 <- gd2014[!is.na(gd2014$`[0,1]1`),]

birds15 <- birds15[birds15$ir %in% surv15$ir,]
surv15 <- surv15[surv15$ir %in% birds15$ir,]
surv15 <- surv15[,2:3]
surv15[surv15>=1] <- 1
gd2015 <- as.data.frame(formatDistData(birds15, "distance","ir",dist.breaks,"night",surv15))
gd2015$ir <- rownames(gd2015)
gd2015$year <- 2015

gd2015 <- gd2015[!is.na(gd2015$`[0,1]2`),]
gd2015 <- gd2015[!is.na(gd2015$`[0,1]1`),]

####-----------------------------------------------
# Input covariates ----------------------------------------------------------------------------------------
####----------------------------------------------

veg <- read.csv("C:/Users/avand/Documents/data/all_veg.csv", header=T) 

## 2012 ##
veg12 <- veg[veg$year==2012,]
veg122 <- veg12[veg12$round==2,]
veg122$round <- 1
veg12 <- rbind(veg122, veg12)
veg12nv <- veg12[veg12$area=="nvca",]
veg12nv <- rbind(veg12nv, veg12nv)
veg12nv[1:84,"round"] <- 1
veg12nv[85:168,"round"] <- 2
veg12 <- rbind(veg12nv, veg12)
veg12sc <- veg12[veg12$area=="scnwr",]
veg12sc$round <- 3
veg12 <- rbind(veg12, veg12sc)
veg12sc <- veg12[veg12$area=="tsca",]
veg12sc$round <- 3
veg12 <- rbind(veg12, veg12sc)
vegss <- veg12[,c(14:30,34:36)]
vegss <- scale(vegss)
colnames(vegss) <- paste("scale", colnames(vegss), sep = "_")
veg12 <- cbind(veg12[,c("year","round","region","area",'impound',"int","short","tall","pe","pcgrass","up","bg","water","wood","other","crop","averagewater","waterp","woodp","dead")],vegss[,c(1:3,6:17)])

#clipping it down to just Moist Soil plots 

veg12 <- veg12[!(veg12$impound=="boardwalk"|veg12$impound=="ditch"|veg12$impound=="n mallard"|veg12$impound=="nose"|veg12$impound=="r4/5"|veg12$impound=="redhead slough"|veg12$impound=="ts11a"|veg12$impound=="sg "),]

melt12 <- melt(veg12, id=c("impound","round","region","area"))
melt12$ir <- paste(melt12$impound, melt12$round, sep="_")
cast12 <- cast(melt12, ir +impound+ area + round + region ~ variable, mean, fill=NA_real_,na.rm=T)


surv12 <- surv[surv$year==2012,]
surv12 <- surv12[(surv12$impound %in% intersect(surv12$impound, cast12$impound)),]

mlen12 <- melt(surv12, id=c("impound","round","night","year"), na.rm=T)
clen12 <- cast(mlen12, impound + round~ variable, max, fill=NA_real_,na.rm=T)
clen12$ir <- paste(clen12$impound, clen12$round, sep="_")

nclen12 <- clen12[(clen12$ir %in% intersect(clen12$ir, cast12$ir)),]
ncast12 <- cast12[(cast12$ir %in% intersect(clen12$ir, cast12$ir)),]


veg12 <- merge(clen12[,c("ir","length","jdate")], cast12, by="ir")



#####################################
### 2013 ### ----------------------------------------------------------------------------------------
#####################################

veg13 <- veg[veg$year==2013,]
vegss <- veg13[,c(14:30,34:36)]
vegss <- scale(vegss)
colnames(vegss) <- paste("scale", colnames(vegss), sep = "_")
veg13 <-  cbind(veg13[,c("year","round","region","area",'impound',"int","short","tall","pe","pcgrass","up","bg","water","wood","other","crop","averagewater","waterp","woodp","dead")],vegss[,c(1:4,6:ncol(vegss))])
#clipping it down to just Moist Soil plots 
veg13 <- veg13[!(veg13$impound=="boardwalk"|veg13$impound=="ditch"|veg13$impound=="n mallard"|veg13$impound=="nose"|veg13$impound=="r4/5"|veg13$impound=="redhead slough"|veg13$impound=="ts11a"|veg13$impound=="sg "|veg13$impound=="bb2"|veg13$impound=="sgd"),]

melt13 <- melt(veg13, id=c("impound","round","region","area"))
cast13 <- cast(melt13, impound + region + area + round ~ variable, mean, fill=NA_real_,na.rm=T)
cast13$ir <- paste(cast13$impound, cast13$round, sep="_")
mlen13 <- melt(surv[surv$year==2013,], id=c("impound","round","night","year"), na.rm=T)
clen13 <- cast(mlen13, impound + round ~ variable, max, fill=NA_real_,na.rm=T)
clen13$ir <- paste(clen13$impound, clen13$round, sep="_")

veg13 <- merge(clen13, cast13, by="ir", all=FALSE)
veg13 <- veg13[,c(1,4:ncol(veg13))]
colnames(veg13)[4]<- "impound"
colnames(veg13)[7]<- "round"

### 2014 ###
v14 <- veg[veg$year==2014&veg$averagewater<900,]
v14$treat[v14$impound=="sanctuary"|v14$impound=="scmsu2"|v14$impound=="pool2w"|v14$impound=="m10"|v14$impound=="ts2a"|v14$impound=="ts4a"|v14$impound=="ccmsu12"|v14$impound=="kt9"|v14$impound=="dc22"|v14$impound=="os23"|v14$impound=="pool i"|v14$impound=="pooli"|v14$impound=="ash"|v14$impound=="sgb"|v14$impound=="scmsu3"|v14$impound=="m11"|v14$impound=="kt2"|v14$impound=="kt6"|v14$impound=="r7"|v14$impound=="poolc"|v14$impound=="pool c"]<-"E"
v14$treat[v14$impound=="sgd"|v14$impound=="rail"|v14$impound=="pool2"|v14$impound=="m13"|v14$impound=="ts6a"|v14$impound=="kt5"|v14$impound=="dc14"|v14$impound=="os21"|v14$impound=="pool e"|v14$impound=="poole"|v14$impound=="r3"|v14$impound=="dc20"|v14$impound=="dc18"|v14$impound=="ccmsu2"|v14$impound=="ccmsu1"|v14$impound=="ts8a"|v14$impound=="pool3w"]<-"L"
v14$woodp = ifelse(v14$wood>0,1,0)
v14$waterp = ifelse(v14$averagewater>0,1,0)
meltv14v = melt(v14[,c( "region","round","impound", "area", "int", "treat", "short","pe", "wood")],id=c("impound","round","treat","region","area"), na.rm=T)
castveg14v = cast(meltv14v, impound + area+  treat + region ~ variable, mean, fill=NA_real_,na.rm=T)
castr <- rbind(castveg14v,castveg14v,castveg14v,castveg14v)
castr$round <- rep(c(1,2,3,4),each=35)
castr$ir <- paste(castr$impound, castr$round, sep="_")

meltv14w = melt(na.omit(v14[,c( "impound","round", "averagewater")]),id=c("impound","round"), na.rm=T)
castveg14w = cast(meltv14w, impound + round~ variable  ,na.rm=T, mean, fill=NA_real_)
castveg14w$ir <- paste(castveg14w$impound, castveg14w$round, sep="_")
castveg14_all <- merge(castr, castveg14w, by="ir")

castss <- scale(castveg14_all[,c(6:9,13)])
colnames(castss) <- paste("scale", colnames(castss), sep = "_")
castveg14 <- cbind(castveg14_all, castss)
castveg14 <- castveg14[,c(1:10,13:ncol(castveg14))]

mlen14 <- melt(surv[surv$year==2014,], id=c("impound","round","night","year"),na.rm=T)
clen14 <- cast(mlen14, impound + round ~ variable, max, fill=NA_real_)
clen14$ir <- paste(clen14$impound, clen14$round, sep="_")

veg14 <- merge(clen14, castveg14, by="ir", all=FALSE)
veg14 <- veg14[,c(1:5,7:13,15:ncol(veg14))]


### 2015 ###
v15 <- veg[veg$year==2015&veg$averagewater<900,]
v15$treat[v15$impound=="sanctuary"|v15$impound=="scmsu2"|v15$impound=="pool2w"|v15$impound=="m10"|v15$impound=="ts2a"|v15$impound=="ts4a"|v15$impound=="ccmsu12"|v15$impound=="kt9"|v15$impound=="dc22"|v15$impound=="os23"|v15$impound=="pool i"|v15$impound=="pooli"|v15$impound=="ash"|v15$impound=="sgb"|v15$impound=="scmsu3"|v15$impound=="m11"|v15$impound=="kt2"|v15$impound=="kt6"|v15$impound=="r7"|v15$impound=="poolc"|v15$impound=="pool c"]<-"L"
v15$treat[v15$impound=="sgd"|v15$impound=="rail"|v15$impound=="pool2"|v15$impound=="m13"|v15$impound=="ts6a"|v15$impound=="kt5"|v15$impound=="dc15"|v15$impound=="os21"|v15$impound=="pool e"|v15$impound=="poole"|v15$impound=="r3"|v15$impound=="dc20"|v15$impound=="dc18"|v15$impound=="ccmsu2"|v15$impound=="ccmsu1"|v15$impound=="ts8a"|v15$impound=="pool3w"|v15$impound=="dc14"]<-"E"
v15$woodp = ifelse(v15$wood>0,1,0)
v15$waterp = ifelse(v15$averagewater>0,1,0)
#v15[v15$impound=="dc14",]$treat <- "E"
meltv15v = melt(v15[,c( "region","round","impound", "area", "int", "treat", "short","pe", "wood")],id=c("impound","round","treat","region","area"), na.rm=T)
castveg15v = cast(meltv15v, impound + area+  treat + region ~ variable, mean, fill=NA_real_,na.rm=T)
castr <- rbind(castveg15v,castveg15v,castveg15v,castveg15v)
castr$round <- rep(c(1,2,3,4),each=nrow(castveg15v))
castr$ir <- paste(castr$impound, castr$round, sep="_")

meltv15w = melt(na.omit(v15[,c( "impound","round", "averagewater")]),id=c("impound","round"), na.rm=T)
castveg15w = cast(meltv15w, impound + round~ variable  ,na.rm=T, mean, fill=NA_real_)
castveg15w$ir <- paste(castveg15w$impound, castveg15w$round, sep="_")
castveg15_all <- merge(castr, castveg15w, by="ir")

castss <- scale(castveg15_all[,c(6:9,13)])
colnames(castss) <- paste("scale", colnames(castss), sep = "_")
castveg15 <- cbind(castveg15_all, castss)
castveg15 <- castveg15[,c(1:10,13:ncol(castveg15))]

mlen15 <- melt(surv[surv$year==2015,], id=c("impound","round","night","year"),na.rm=T)
clen15 <- cast(mlen15, impound + round ~ variable, max, fill=NA_real_)
clen15$ir <- paste(clen15$impound, clen15$round, sep="_")

veg15 <- merge(clen15, castveg15, by="ir", all=FALSE)
veg15 <- veg15[,c(1:5,7:13,15:ncol(veg15))]



veg12 <- veg12[(veg12$ir %in% gd2012$ir),]
veg13 <- veg13[(veg13$ir %in% gd2013$ir),]
veg14 <- veg14[(veg14$ir %in% gd2014$ir),]
veg15 <- veg15[(veg15$ir %in% gd2015$ir),]

gd2012 <- gd2012[(gd2012$ir %in% veg12$ir),]
gd2013 <- gd2013[(gd2013$ir %in% veg13$ir),]
gd2014 <- gd2014[(gd2014$ir %in% veg14$ir),]
gd2015 <- gd2015[(gd2015$ir %in% veg15$ir),]

### create bird input files ----------------------------------------------------------------------------------------

write.csv(gd2012, "C:/Users/avand/Documents/data/2012_sora.csv", row.names=F)
write.csv(gd2013, "C:/Users/avand/Documents/data/2013_sora.csv", row.names=F)
write.csv(gd2014, "C:/Users/avand/Documents/data/2014_sora.csv", row.names=F)
write.csv(gd2015, "C:/Users/avand/Documents/data/2015_sora.csv", row.names=F)

# Create Covariate Files ----------------------------------------------------------------------------------------

write.csv(veg12, "C:/Users/avand/Documents/data/2012_cov.csv", row.names=F)
write.csv(veg13, "C:/Users/avand/Documents/data/2013_cov.csv", row.names=F)
write.csv(veg14, "C:/Users/avand/Documents/data/2014_cov.csv", row.names=F)
write.csv(veg15, "C:/Users/avand/Documents/data/2015_cov.csv", row.names=F)
