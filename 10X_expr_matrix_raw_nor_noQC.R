library(cellrangerRkit)

args=commandArgs(TRUE)
sample_name<-args[2]
cellranger_pipestance_path <-args[1]
print(cellranger_pipestance_path)
gbm <- load_cellranger_matrix(cellranger_pipestance_path)
#	analysis_results <- load_cellranger_analysis_results(cellranger_pipestance_path)
use_genes <- get_nonzero_genes(gbm)
gbm_bcnorm <- normalize_barcode_sums_to_median(gbm[use_genes,])
#gbm_log <- log_gene_bc_matrix(gbm_bcnorm,base=10)
gbm_log<-gbm_bcnorm
print(dim(gbm))
print(dim(gbm_log))
densematrix<-as.matrix(exprs(gbm_log))
densematrix_raw<-as.matrix(exprs(gbm))
final<-cbind(fData(gbm_log)[rownames(densematrix),],densematrix)
final_raw<-cbind(fData(gbm)[rownames(densematrix_raw),],densematrix_raw)

raw_name<-paste(sample_name,"Expr_raw.csv",sep="_")
norm_name<-paste(sample_name,"Expr_norm.csv",sep="_")

write.csv(final,paste(cellranger_pipestance_path,norm_name,sep="/"),quote=F,row.names = FALSE)
	
#	write.table(final,"NN1_TN1_expr_log_norm.txt",quote = F,sep="\t",row=F)
write.csv(final_raw,paste(cellranger_pipestance_path,raw_name,sep="/"),quote = F,row.names = FALSE)

