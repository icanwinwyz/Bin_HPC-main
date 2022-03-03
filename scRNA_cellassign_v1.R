library(Seurat)
library(cellassign)
library(scran)
library(pheatmap)

args=commandArgs(TRUE)
raw_expr_matrix<-args[2] ####first input file is the raw count expression matrix
marker_matrix<-args[1]  ####second input file is the biomarker matrix
data<-read.csv(raw_expr_matrix,header=T,row.names=1)  
object <- CreateSeuratObject(counts = data, min.cells = 3, min.features = 100)  ####Creat a Seurat object
object<-as.SingleCellExperiment(object) ####Convert the object into single cell experiment object

ma<-read.table(marker_matrix,sep="\t",header=T,stringsAsFactors = F) ####read in the biomarker matrix
ma<-as.data.frame(ma) ####convert the format into data frame
marker_list<-c() ####create a empty list 
for (i in 1:(nrow(ma))){ ##### use biomarker matrix as the input to generate the list to be comaptible with cell assign
  b<-c()
  b <- strsplit(ma$marker[i],",")
  names(b)<-as.vector(ma$type[i])
  marker_list<-c(marker_list,b)
}
#marker_list<-list(Rod_photoreceptors = c("Pde6a", "Cnga1","Rho"),Cone_photoreceptors=c("Opn1sw","Arr3","Gngt2"),Muller_glia = #c("Sox2","Aqp4","Abca8a","Gpr37"),Retinal_astrocytes=c("Gfap","Gja1"),Microglia=c("Hexb","Trem2","Gpr34","Tmem119","Cx3cr1","P2ry12"),Bipolar_cells=c("Gnb3","Vsx1","Grm6","Scgn","Trpm1"),Retinal_ganglion_cells=c("Nefl","Gap43","Pcdh8","Shh","Cacng3","Sgsm1","Txnrd3"),Amacrine_cells=c("Gad1","Calb1","Prox1"),Horizontal_cells=c("Onecut1"),Vascular_cells=c("Tm4sf1","Cldn5"))
print(head(marker_list))
marker_list <- marker_list_to_mat(marker_list) #### convert the list format into cell assign compatible format
marker_intersect <- intersect(rownames(marker_list), rownames(object)) ####check the overlapped biomarker with gene names in expression matrix
marker_list <- marker_list[marker_intersect,,drop=F] 
object<-computeSumFactors(object) ####calculate the size factor
s<-sizeFactors(object)
print(head(marker_list))
object_sub <- object[intersect(marker_intersect, rownames(object)),]  ####generate the expression matrix for biomarkers only 
print(object_sub)
fit <- cellassign(exprs_obj = object_sub,marker_gene_info = marker_list,s = s,learning_rate = 1e-2,shrinkage = TRUE,verbose = TRUE,threads=25) ####start the cell assign for cell population identification
pdf("cellassign_biomarker_heatmap.pdf") ####generate the heatmap for biomarker
pheatmap::pheatmap(cellprobs(fit))
dev.off()
final<-data.frame(colnames(object),celltypes(fit))
final[,1]<-paste(final[,1],"-1",sep="")
colnames(final)<-c("Barcode","Cell_label")
write.csv(final,"cellassign_biomarker_label.csv",row.names=F,quote=F,sep=",") ####generate the barcode and population matrix for cloupe uploading
print("Done for cell population identification")
