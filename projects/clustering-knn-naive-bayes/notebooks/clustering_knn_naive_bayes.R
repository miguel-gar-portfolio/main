# Package installation
paquetes<-c('ggplot2','cluster','factoextra','ks','kknn','cat','naivebayes','pROC')
for (i in 1:length(paquetes))
{
  if(require(paquetes[i],character.only = TRUE)) cat(paquetes[i], " loaded successfully\n") 
  else {
    cat("Trying to install",paquetes[i])
    install.packages(paquetes[i])
    if(require(paquetes[i],character.only = TRUE)) cat(paquetes[i], " loaded successfully")   
    else {
      stop("Could not install ", paquetes[i])
    }
  }
}

# First five digits of the national ID (seed)
m <- 29509

# Load data-generation script
source("data/GenerarDatos.R")

# Inspect structure
str(datosred)

X <- datosred[, !(names(datosred) %in% "label")]
X_scaled <- scale(X)

factoextra::fviz_nbclust(x = X_scaled, FUNcluster = kmeans, method = "silhouette", k.max = 15) +
  labs(title = "Optimal number of clusters")

km <- kmeans(X_scaled, centers = 2, nstart = 25)

# Size of each cluster
km$size

# Cluster centres
km$centers

datosred_copy <- datosred
datosred_copy$cluster_kmeans <- as.factor(km$cluster)

fviz_cluster(object = km, data = X_scaled, show.clust.cent = TRUE, ellipse.type = "euclid",
             star.plot = TRUE, repel = TRUE) + ggplot2::labs(title = "K-means plot") + 
  theme_bw() + theme(legend.position = "none") 

dist_matrix <- dist(X_scaled)
hc <- hclust(dist_matrix, method = "ward.D2")
plot(
  hc,
  main = "Dendrogram - Ward method",
  sub = "",
  xlab = "",
  ylab = "Distance",
  cex = 0.6,          # smaller labels
  hang = -1           # align leaves
)
rect.hclust(hc, k = 2, border = "red")

heatmap(as.matrix(dist_matrix),main = "Heatmap")

clusters_hc <- cutree(hc, k = 2)
datosred_copy$cluster_hier <- as.factor(clusters_hc)

levels(datosred_copy$cluster_kmeans) <- c("Pullover", "Ankle boot")
levels(datosred_copy$cluster_hier) <- c("Pullover", "Ankle boot")

#k-means
table(datosred_copy$cluster_kmeans, datosred_copy$label)
#Hierarchical clustering
table(datosred_copy$cluster_hier, datosred_copy$label)

set.seed(12345)

m <- dim(datosred)[1]  # number of cases

test <- sample(1:m, size = round(m/3), replace = FALSE,
               prob = rep(1/m, m)) 

# training set
x_train <- datosred[-test,]
# test set
x_test <- datosred[test,]  

# Weighted KNN on the data
knn_model_cv <- train.kknn(label ~ ., x_train, kmax = 15,
                           kernel = c("triangular", "rectangular",
                                      "epanechnikov", "optimal","biweight",
                                      "triweight","gaussian","cos", "inv"), 
                           distance = 1)
knn_model_cv

plot(knn_model_cv,main="WkNN classification on datosred")

fit_test <- predict(knn_model_cv, newdata = x_test)
confusion_matrix <- table("True_class"= x_test$label, "WkNN_class"= fit_test)
confusion_matrix

prop.table(confusion_matrix)

best_knn_model = kknn(label ~ ., train=datosred, test = datosred, k=2,
                      kernel="rectangular", distance=1)

table(datosred$label, predict(best_knn_model))
erroremp<- mean(datosred$label!=predict(best_knn_model))
cat("Empirical error =",100*erroremp ,"% \n")

B<- 2000 # number of bootstrap samples
set.seed(13579)

###### Variables ########
errorboot=numeric(B)
errorOOBb=numeric(B)
n= nrow(datosred)
Preditodos=matrix("",n,B)
IndicesOOB=matrix(0,n,B)
#########################


# Bootstrap loop
for (b in 1:B)
{ 
  if (b%%200==0) cat("Bootstrap sample number ",b,"\n")
  # Generate bootstrap sample of indices
  indib<- sample(n,rep=T)
  # Indices not included in indib
  indiOOB<-setdiff(1:n,indib)
  # Fit model on the bootstrap sample
  boot_model<-kknn(label ~ ., train=datosred[indib,], test = datosred, 
                   k=2, kernel="rectangular", distance=1)
  # Predictions of this model on the training sample
  full_prediction = predict(boot_model)
  # Error rate on the original sample
  errorboot[b]<- mean(full_prediction != datosred$label) 
  # Store the n predictions for model b
  # as.character so category labels are stored instead of 1 and 2
  Preditodos[,b]=as.character(full_prediction) 
  #print(preditodos[,b])
  # Cases not included in bootstrap sample b
  IndicesOOB[indiOOB,b] =1
  errorOOBb<- mean(Preditodos[indiOOB,b] != datosred$label[indiOOB])
}


# Bootstrap and OOB error
errorB<- mean(errorboot)
errorOOB<- mean(errorOOBb)

labels <- datosred$label
pred   <- best_knn_model$fitted.values

######### Variables #########
classes <- levels(labels)
noinf <- 0
#############################

# Loop to compute noinf
for (i in classes) {
  # Class proportion
  pi <- sum(labels == i) / n
  
  # Class-specific error
  qi <- sum(pred[labels == i] != i) / n
  
  noinf <- noinf + pi * (1 - qi)
}

# Weighting coefficient w
tsr = (errorOOB - erroremp) / (noinf - erroremp)
w = (0.632) / (1 - 0.368 * tsr)

# 632+ error
error632plus = (1 - w) * erroremp + w * errorOOB
error632plus

tsr

# partition
set.seed(12345)
m <- dim(datos)[1]  
train <- sample(1:m, size = round(0.75*m), replace = FALSE, prob = rep(1/m, m))
# training data set
test <- datos[-train,]

model_nb <- naive_bayes(label ~ ., data = datos[train,],usekernel = TRUE)
pred_nb = predict(model_nb, test, type = "class")
table(test$label, pred_nb)

# overall accuracy
accuracy <- sum(pred_nb == test$label) / nrow(test)
cat("Overall accuracy:", round(accuracy * 100, 2), "%\n")
   
# per-class accuracy
acierto_por_categoria <- prop.table(table(test$label, pred_nb), 1)
acierto_por_categoria_df <- as.data.frame(acierto_por_categoria)
colnames(acierto_por_categoria_df) <- c("Category", "Prediction", "Accuracy")
print(acierto_por_categoria_df)

# ROC curve and AUC
# Prediction probabilities are needed for the ROC curve
pred_nb_prob <- predict(model_nb, test, type = "prob")
roc_obj <- roc(test$label, pred_nb_prob[, 2], levels = rev(levels(test$label)))
plot(roc_obj)

auc_value <- auc(roc_obj)
cat("AUC:", round(auc_value, 4), "\n")
