library(Seurat)
args=commandArgs(TRUE)
path<-args[1]
barcode_file<-args[2]
name<-args[3]
data<-Read10X(data.dir = path)
pbmc = CreateSeuratObject(counts = data$`Gene Expression`)
barcode<-read.csv(barcode_file,header=T)

barcode[,1]<-sub("-1","",barcode[,1])

tag<-pbmc[,barcode[,1]]

tag<-NormalizeData(object = tag)

tag_raw<-GetAssayData(object = tag, slot = "counts")
tag_norm<-GetAssayData(object = tag, slot = "data")

raw_name<-paste(name,"Expr_raw.csv",sep="_")
norm_name<-paste(name,"Expr_norm.csv",sep="_")

write.csv(tag_raw,raw_name,quote=F,row.names = TRUE)
write.csv(tag_norm,norm_name,quote=F,row.names = TRUE)
