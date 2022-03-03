library(cellrangerRkit)

args=commandArgs(TRUE)
path<-args[1]
path_barcode<-args[2]
print(path)
print(path_barcode)

gbm <- load_cellranger_matrix(path)
cells<-read.table(path_barcode,header=T)
cells<-as.vector(cells[,1])
subset_by_cell <- gbm[,cells]
use_genes <- get_nonzero_genes(subset_by_cell)
gbm_bcnorm <- normalize_barcode_sums_to_median(subset_by_cell[use_genes,])
gbm_log<-gbm_bcnorm
densematrix<-as.matrix(exprs(gbm_log))
densematrix_raw<-as.matrix(exprs(gbm))
final<-cbind(fData(gbm_log)[rownames(densematrix),],densematrix)
final_raw<-cbind(fData(gbm)[rownames(densematrix_raw),],densematrix_raw)
write.csv(final,"Expr_norm_filter.csv",quote=F,row.names = FALSE)
write.csv(final_raw,"Expr_raw_filter.csv",quote = F,row.names = FALSE)
