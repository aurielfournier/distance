M <- 250                                # Number of sites
J <- 3                                  # num secondary sample periods
T <- 10                                 # num primary sample periods
psi <- rep(NA, T)                       # Occupancy probability
muZ <- z <- array(dim = c(M, T))        # Expected and realized occurrence
y <- array(NA, dim = c(M, J, T))        # Detection histories
set.seed(13973)
psi[1] <- 0.4                           # Initial occupancy probability
p <- c(0.3,0.4,0.5,0.5,0.1,0.3,0.5,0.5,0.6,0.2)
phi <- runif(n=T-1, min=0.6, max=0.8)   # Survival probability (1-epsilon


gamma <- runif(n=T-1, min=0.1, max=0.2) # Colonization probability
# Generate latent states of occurrence
# First year
z[,1] <- rbinom(M, 1, psi[1])           # Initial occupancy state
# Later years
for(i in 1:M){                          # Loop over sites
for(k in 2:T){                        # Loop over years
muZ[k] <- z[i, k-1]*phi[k-1] + (1-z[i, k-1])*gamma[k-1]
z[i,k] <- rbinom(1, 1, muZ[k])
}
}
# Generate detection/non-detection data
for(i in 1:M){
for(k in 1:T){
prob <- z[i,k] * p[k]
for(j in 1:J){
y[i,j,k] <- rbinom(1, 1, prob)
}
}
}
# Compute annual population occupancy
for (k in 2:T){
psi[k] <- psi[k-1]*phi[k-1] + (1-psi[k-1])*gamma[k-1]
}


library(unmarked)

yy <- matrix(y, M, J*T)



year <- matrix(c('01','02','03','04','05','06','07','08','09','10'),nrow(yy),T,byrow=TRUE)



simUMF <- unmarkedMultFrame(y = yy,yearlySiteCovs = list(year = year),numPrimary=T)


summary(simUMF)


m0 <- colext(psiformula= ~1, gammaformula = ~ 1, epsilonformula = ~ 1, pformula = ~ 1, data = simUMF, method="BFGS")
