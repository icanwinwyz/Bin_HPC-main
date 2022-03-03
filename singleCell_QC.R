library(gplots)
library(genefilter)
library(vegan)
library(cluster)
library(FactoMineR)

args= commandArgs(TRUE)
name=args[1]
tpm=paste(name,".all.tpm",sep='')
count=paste(name,".all.count",sep='')
id=unlist(strsplit(name,'[_]'))[2]

(tpm)
(count)
(id)
b=read.table(count,sep='\t',header=T,row.names=1,check.names=F)
b=as.matrix(round(b))
colnames(b)=matrix(unlist(strsplit(colnames(b),'[.]')),byrow=T,ncol=3)[,1]
#colnames(b)=matrix(unlist(strsplit(colnames(b),'[.]')),byrow=T,ncol=2)[,1]
pdf(file=paste(count,".pdf",sep=''),16,9)
rarecurve(t(b),step=10000,cex=0.8,col="blue",ylab="Gene",xlab="Sequencing depth")
dev.off()

a=read.table(tpm,sep='\t',header=T,row.names=1,check.names=F)
colnames(a)=matrix(unlist(strsplit(colnames(a),'[.]')),byrow=T,ncol=3)[,1]
#colnames(a)=paste(matrix(unlist(strsplit(colnames(a),'[.]')),byrow=T,ncol=2)[,1],id,sep='.')
#colnames(a)=matrix(unlist(strsplit(colnames(a),'[.]')),byrow=T,ncol=2)
#b=readLines('~/work/Barry/Human_protein_genes.txt')
#a=a[b,]
a=as.matrix(a)
lod=ifelse(a<2,1,a)
log_lod=log2(lod)
housekeeping=log_lod[rowSums(log_lod>0)>(ncol(log_lod)/2),]
dim(housekeeping)
pdf(file=paste(tpm,".pdf",sep=''),16,9)
par(mar=c(10,6,1,1))
boxplot(log_lod[rowSums(log_lod>0)>(ncol(log_lod)/2),],las=2, ylab =expression(log[2](intensity)),cex.axis=.7)
dev.off()

log_lod=log_lod[rowMeans(log_lod)>0,]
dat.norm=t(log_lod)
res.pca=PCA(dat.norm,ncp=5,scale.unit=T,graph=F)
pdf(file=paste(name,"_PCA.pdf",sep=''),16,9)
plot.PCA(res.pca,cex=0.8)
dev.off()
