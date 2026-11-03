#Seleccionar los datos
set.seed(m)
load(file="data/raw/datos.RData")
dosprendas=sample(levels(datos$label),2)
diezvar=sort(sample(1:784,10)+1)
datos=datos[datos$label %in% dosprendas,c(1,diezvar)]
datos$label=factor(datos$label)
datos=datos[sample(nrow(datos),1000),]
datos[,-1]=datos[,-1]+matrix(runif(10000,0,5),ncol=10)
summary(datos)
datosred=datos[sample(nrow(datos),75),]

