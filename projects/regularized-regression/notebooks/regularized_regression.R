knitr::opts_chunk$set(echo = TRUE)

# Package installation
packages <- c('glmnet','Rcpp','foreach','survival','shape','utils','methods','Matrix','car')
for (i in 1:length(packages))
{
  if(require(packages[i],character.only = TRUE)) cat(packages[i], " loaded successfully\n") 
  else {
    cat("Trying to install", packages[i], "\n")
    install.packages(packages[i])
    if(require(packages[i],character.only = TRUE)) cat(packages[i], " loaded successfully\n")   
    else {
      stop("Could not install ", packages[i])
    }
  }
}

# Data extraction and preparation (drop 6 variables by ID digits)
load("data/raw/AEM_03_Regularization_data.RData")

a=9 
b=3
c=5
d=6 
elim=c(19,29,39,13,23,43) 
datos=datos[,-elim] 

# Multiple linear model
lm.fit <- lm(Y~.,data=datos)
summary(lm.fit)

par(mfrow=c(2,2))
plot(lm.fit)

vif(lm.fit) 

det(vcov(lm.fit))

# Elastic-net regularization over a grid of alpha
mx=as.matrix(datos[,2:ncol(datos)])  
my=as.matrix(datos[,1])

alphas <- c(0, 0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95, 1)

cv_models <- lapply(alphas, function(a) {
  set.seed(123)
  cv.glmnet(mx,my,keep=TRUE, alpha = a)
})

# Select lambda.1se metrics for each alpha
cv_1se <- function(cv_models, alphas){
  cv_errors_1se <- sapply(cv_models, function(model) {
    model$cvm[which(model$lambda == model$lambda.1se)]
  })
  cv_lambda_index <- sapply(cv_models, function(model) {
    which(model$lambda == model$lambda.1se)
  })
  cv_lambda_value <- sapply(cv_models, function(model) {
    model$lambda[which(model$lambda == model$lambda.1se)]
  })
  
  df<- data.frame(
    cvm = cv_errors_1se,
    lambda_index = cv_lambda_index,
    lambda = cv_lambda_value,
    alphas = alphas
  )
  return(df)
}

df=cv_1se(cv_models,alphas)
df

best_alpha_model_index <-which(df$cvm == min(df$cvm))
best_alpha_model_params <- df[best_alpha_model_index,]
best_alpha_model_params

set.seed(123)
best_alpha_model = cv.glmnet(mx,my,keep=TRUE, alpha = 0.45)

nCVopt = which(best_alpha_model$lambda == best_alpha_model$lambda.1se)
best_alpha_model$lambda[nCVopt]

plot(best_alpha_model)

best_alpha_model$glmnet.fit

coef(best_alpha_model)

mxpred=mx[1001:1010,]  
predict(best_alpha_model, mxpred, s = best_alpha_model$lambda.1se, type="link")
