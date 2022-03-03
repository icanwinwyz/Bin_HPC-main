###you should "module load R" first, then there should be no error loading Seurat
#######argument 1 is path to the expression matrix and argument 2 is name for the QC report(sample name) and argument 3 is the single sample or aggregation samples 



library(Seurat)
library(dplyr)
library(Matrix)
library(methods)
library(gplots)
packageVersion("Seurat")

args=commandArgs(TRUE)
path<-args[1]
name<-args[2]
type<-args[3]

pbmc.data<-Read10X(data.dir = path)
pbmc <- CreateSeuratObject(raw.data = pbmc.data, min.cells = 0, min.genes = 0,project = name)
mito.genes <- grep(pattern = "^MT-", x = rownames(x = pbmc@data), value = TRUE,ignore.case = T)
#percent.mito <- colSums(pbmc@raw.data[mito.genes, ])/colSums(pbmc@raw.data)
percent.mito <-Matrix::colSums(pbmc@raw.data[mito.genes, ])/Matrix::colSums(pbmc@raw.data)
pbmc <- AddMetaData(object = pbmc, metadata = percent.mito, col.name = "percent.mito")
pdf(paste(name,"QC.pdf",sep="_"),16,9)

temp1<-FilterCells(object = pbmc, subset.names = c("percent.mito"),low.thresholds = c(-Inf), high.thresholds = c(0.15))
a<-dim(pbmc@raw.data)[2]-dim(temp1@data)[2]
temp2 <- FilterCells(object = pbmc, subset.names = c("nGene"),low.thresholds = c(300), high.thresholds = c(Inf))
b<-dim(pbmc@raw.data)[2]-dim(temp2@data)[2]
pbmc_filter <- FilterCells(object = pbmc, subset.names = c("nGene", "percent.mito"),low.thresholds = c(300, -Inf), high.thresholds = c(Inf, 0.15))
c<-dim(pbmc_filter@data)[2]
d<-dim(pbmc@data)[2]
text1<-paste("Sample Name:",name,sep=" ")
text2<-paste(a,"cells failed mito% < 15%",sep=" ")
text3<-paste(b,"cells failed total # expressed genes > 300.",sep=" ")
text4<-paste("There are",c,"out of",d,"cells remained after filtering.",sep=" ")
text<-paste(text1,text2,text3,text4,sep="\n");
textplot(text,halign="center",valign="center",cex=2)


textplot("Before Filtering",halign="center",valign="center",cex=5)
print(VlnPlot(object = pbmc, features.plot = c("nGene", "nUMI", "percent.mito"), nCol = 3))
##par(mfrow = c(1, 2))
print(GenePlot(object = pbmc, gene1 = "nUMI", gene2 = "percent.mito"))
print(GenePlot(object = pbmc, gene1 = "nUMI", gene2 = "nGene"))
textplot("After Filtering",halign="center",valign="center",cex=5)
print(VlnPlot(object = pbmc_filter, features.plot = c("nGene", "nUMI", "percent.mito"), nCol = 3))
print(GenePlot(object = pbmc_filter, gene1 = "nUMI", gene2 = "percent.mito"))
print(GenePlot(object = pbmc_filter, gene1 = "nUMI", gene2 = "nGene"))
dev.off()

if(type == "aggre"){
barcode<-colnames(pbmc_filter@data)
barcode<-data.frame(Barcode=barcode)
write.csv(barcode,paste(name,"barcode_filter.csv",sep="_"),row.names = F,quote = F)
}else if(type == "single"){
barcode<-colnames(pbmc_filter@data)
barcode<-data.frame(Barcode=barcode)
barcode[,1]<-paste(barcode[,1],"-1",sep="")
write.csv(barcode,paste(name,"barcode_filter.csv",sep="_"),row.names = F,quote = F)
}
