###this script is based on Seruat v3.0 and titan server install this package

#example: Rscript ./10X_scRNA_QC_filtering_Seurat_v3_reanalyze.R ./Lipo-Fibroblast_results/outs/filtered_feature_bc_matrix/ Lipo-Fibroblast -2

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

test.data <- Read10X(data.dir=path)

# Initialize the Seurat object with the raw (non-normalized data).  Keep all
# genes expressed in >= 0 cells . Keep all cells with at
# least 300 detected genes
test <- CreateSeuratObject(counts = test.data, min.cells = 0, project = name)
test

# The [[ operator can add columns to object metadata. This is a great place to stash QC stats

#human
#test[["percent.mt"]] <- PercentageFeatureSet(test, pattern = "^MT-")

#Mouse
test[["percent.mt"]] <- PercentageFeatureSet(test, pattern = "^mt-")

#rat
#test[["percent.mt"]] <- PercentageFeatureSet(test, pattern = "^Mt-")

# Show QC metrics for the first 5 cells
head(test@meta.data, 5)

# Visualize QC metrics as a violin plot
#VlnPlot(pbmc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)

# FeatureScatter is typically used to visualize feature-feature relationships, but can be used
# for anything calculated by the object, i.e. columns in object metadata, PC scores etc.
plot1 <- FeatureScatter(test, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(test, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")

#CombinePlots(plots = list(plot1, plot2))

#We filter cells that have unique feature counts less than 300
#We filter cells that have >15% mitochondrial counts
test_1 <- subset(test, subset = nFeature_RNA >= 300 & percent.mt <= 15)

plot1_1 <- FeatureScatter(test_1, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2_1 <- FeatureScatter(test_1, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")

#CombinePlots(plots = list(plot1_1, plot2_1))
pdf(paste(name,"_QC.pdf",sep=""),16,12)
test_4 <- subset(test, subset = nFeature_RNA < 300 & percent.mt > 15)
e<-dim(test_4@assays$RNA)[2]
test_2 <- subset(test, subset = percent.mt <= 15)
a<-dim(test@assays$RNA)[2]-dim(test_2@assays$RNA)[2]-e
test_3 <- subset(test, subset = nFeature_RNA >= 300)
b<-dim(test@assays$RNA)[2]-dim(test_3@assays$RNA)[2]-e
c<-dim(test_1@assays$RNA)[2]
d<-dim(test@assays$RNA)[2]
text1<-paste("Sample Name:",name,sep=" ")
text2<-paste(a,"cells failed mito% <= 15%",sep=" ")
text3<-paste(b,"cells failed total # expressed genes >= 300.",sep=" ")
text5<-paste(e,"cells failed total # expressed genes >= 300 and mito% <= 15%.",sep=" ")
text4<-paste("There are",c,"out of",d,"cells remained after filtering.",sep=" ")
text<-paste(text1,text2,text3,text5,text4,sep="\n");

textplot(text,halign="center",valign="center",cex=2)
textplot("Before Filtering",halign="center",valign="center",cex=5)
VlnPlot(test, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
CombinePlots(plots = list(plot1, plot2))
textplot("After Filtering",halign="center",valign="center",cex=5)
VlnPlot(test_1, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
CombinePlots(plots = list(plot1_1, plot2_1))
dev.off()


before_QC<-test@assays$RNA

dim(before_QC)

temp<-test_1@assays$RNA
#dim(temp)
#temp<-temp[,which(temp[grep(paste("^","PECAM1","$",sep=""),rownames(temp),ignore.case=T),]==0)]
#dim(temp)
#temp<-temp[,which(temp[grep(paste("^","PTPRC","$",sep=""),rownames(temp),ignore.case=T),]==0)]
#dim(temp)
#temp<-temp[,which(temp[grep(paste("^","EPCAM","$",sep=""),rownames(temp),ignore.case=T),]==0)]
dim(temp)

tag<-NormalizeData(object = test_1)
tag_raw<-GetAssayData(object = tag, slot = "counts")
tag_norm<-GetAssayData(object = tag, slot = "data")
raw_name<-paste(name,"Expr_raw_QC.csv",sep="_")
norm_name<-paste(name,"Expr_norm_QC.csv",sep="_")

write.csv(tag_raw,raw_name,quote=F,row.names = TRUE)
write.csv(tag_norm,norm_name,quote=F,row.names = TRUE)



#barcode<-colnames(temp)
#barcode<-data.frame(Barcode=barcode)
#barcode[,1]<-paste(barcode[,1],number,sep="")
#write.table(barcode,paste(name,"barcode_filter_single.csv",sep="_"),col.names=F,row.names = F,quote = F)


if(type == "aggre"){
barcode<-colnames(pbmc_filter@data)
barcode<-data.frame(Barcode=barcode)
write.csv(barcode,paste(name,"barcode_filter.csv",sep="_"),row.names = F,quote = F)
}else if(type == "single"){
barcode<-colnames(temp)
barcode<-data.frame(Barcode=barcode)
#for seurat v3.1.5, barcodes AAACCCAAGTTAACAG-1 was stored in seurat object, so no need to add "-1".
#but for earlier seurat version, barcodes AAACCCAAGTTAACAG was stored in seurat object, so have to add "-1".
#barcode[,1]<-paste(barcode[,1],"-1",sep="")
write.csv(barcode,paste(name,"barcode_filter_single.csv",sep="_"),row.names = F,quote = F)
}



#barcodes = paste0(row.names(test_1@meta.data), "-1")
#write.table(barcodes,file = "barcodes_filtered.txt",row.names = FALSE, col.names = FALSE, quote = FALSE)
