#!/usr/bin/Rscript

# Copyright (c) 2017 The ACEseq workflow developers.
# This script is licenced under (license terms are at
# https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

#Kortine Kleinheinz 14.08.14
#This script can be used to correct for gc bias and replication timing starting from tumor and control read counts in 10kb windows
#

library(getopt)

script_dir = dirname(get_Rscript_filename())

#default Parameter
functionPath <- paste0(script_dir, "/correctGCBias_functions.R")
scale_factor <- 0.9
lowess_f <- 0.1

spec <- matrix(c('timefile',	 't', 1, "character"# 'file for replication timing',
		 'windowFile',	 'f', 1, "character"# 'file with 10kb window coordinates and coverage',
		 'chrLengthFile','h', 1, "character"# 'file with chromosomelength',
                 'pid',		 'p', 1, "character"# 'patient ID',
                 'email',	 'e', 1, "character"# "email adress to enable contact in case of evidence for sample errors",
                 'outfile',	 'o', 1, "character"# 'new file with corrected and raw coverage',
                 'corPlot', 	 'c', 1, "character"# 'Name for plot with corrected GC bias',
                 'gcFile',	 'g', 1, "character"# 'table with gc content per 10kb window',
                 'outDir',	 'x', 1, "character"# 'directory for outputfiles',
	         'scaleFactor',	 's', 2, "double"   # 'scaling factor to determine range of points to take as main cloud',
	         'lowess_f',	 'l', 2, "double"   # 'smoothing parameter of lowess function',
		 'functionPath', 'u', 2, "character"# 'path and name of script with functions for script'
                ), ncol = 4, byrow = TRUE)

opt = getopt(spec);

for(item in names(opt)){
       assign( item, opt[[item]])
}


cat(paste0("windowFile: ", windowFile, "\n\n"))
cat(paste0("timefile: ", timefile, "\n\n"))
cat(paste0("pid: ", pid, "\n\n"))
cat(paste0("email: ", email, "\n\n"))
cat(paste0("outfile: ", outfile, "\n\n"))
cat(paste0("corPlot: ", corPlot, "\n\n"))
cat(paste0("gcFile: ", gcFile, "\n\n"))
cat(paste0("outDir: ", outDir, "\n\n"))
cat("\n")

source(functionPath)

plotDir <- dirname(corPlot)
outputfile_gc  <- paste0(corPlot) #includes plotDir already
outputfile_rep <- paste0(plotDir,"/", pid, "_qc_rep_corrected.png")

# define files for output of quantification of correction factors
outrepQuant_file <- paste0(plotDir,"/",pid,"_qc_repQuant.tsv")
outGCcorrectQuant_file <- paste0(plotDir,"/",pid,"qc_GCcorrectQuant.tsv")
plot_flag <- 1
restrict_flag <- 1
writeGCcorrect_flag <- 0

cat("reading input files\n")
file_gc  <- read.table(file=gcFile, header=TRUE ,sep="\t", check.names=FALSE)
file_gc$chromosome <- gsub('X', 23, file_gc$chromosome )
file_gc$chromosome <- gsub('Y', 24, file_gc$chromosome )


file_cov <- read.table(pipe(paste0("cat ", windowFile) ), head=FALSE ,sep="\t", check.names=FALSE)
file_cov <- file_cov[,-3]
colnames(file_cov) <- c('chromosome', 'start', 'normal', 'tumor')

#read replication time data
load(file=timefile)
colnames(time10) <- c('chromosome', 'tenkb', 'time')
time10$chromosome <- gsub('X',23, time10$chromosome)

#read and sort chromosome length file
chrLengthTab = read.table(chrLengthFile, header = FALSE, as.is = TRUE)
chrLengthTab = data.frame(chrLengthTab)
colnames(chrLengthTab)  <- c("chromosome", "length", "info")
chrLengthTab$chromosome <- gsub('chr','',chrLengthTab$chromosome)
chrLengthTab$chromosome <- gsub('X', 23, chrLengthTab$chromosome)
chrLengthTab$chromosome <- gsub('Y', 24, chrLengthTab$chromosome)
chrLengthTab$chromosome <- as.numeric(chrLengthTab$chromosome)
chrLengthTab		<- chrLengthTab[order(chrLengthTab$chromosome),]

#get normalized coverage and adjust coordinates
file_cov$covN <- file_cov$normal / sum(as.numeric(file_cov$normal))
file_cov$covT <- file_cov$tumor / sum(as.numeric(file_cov$tumor))
file_cov$covR <- file_cov$covT / file_cov$covN

file_cov$start <- floor(file_cov$start/1000)*1000
file_cov$chromosome <- gsub('chr', '', file_cov$chromosome)

#merge dataframes
file_comb <- merge( x = file_cov,
		y = file_gc,
		by=c('chromosome','start'),
		sort =F)
rm(file_gc)
rm(file_cov)
gc()

cat("correction for gc bias...\n")
#reorder original sample according to gc_content
order_file <- file_comb[order(file_comb$gc_content),]

#compute correction for gc bias by fits
normal_fit  <- lowess(order_file$gc_content,order_file$covN, lowess_f)
normal_mean <- mean(order_file$covN)
normal_mean_vector <- matrix(normal_mean,length(order_file$gc_content))
tumor_fit <- lowess(order_file$gc_content,order_file$covT, lowess_f)
tumor_mean <- mean(order_file$covT)
tumor_mean_vector <- matrix(tumor_mean,length(order_file$gc_content))
#compute correction for gc bias by fit from all points
order_file$corrected_covN <- order_file$covN/normal_fit$y
order_file$corrected_covT <- order_file$covT/tumor_fit$y
order_file$corrected_covR <- order_file$corrected_covT/order_file$corrected_covN

###isolate main cluster in normal sample

# modify call to the function defineMainCluster to return also the width of the main cluster
temp_main_cluster_n <- defineMainCluster(order_file$covN, normal_fit)
my_main_cluster_ind_n <- temp_main_cluster_n$ind
my_main_cluster_width_n <-temp_main_cluster_n$width

main_cluster_n <- data.frame(covN = order_file$covN[my_main_cluster_ind_n], gc_content = order_file$gc_content[my_main_cluster_ind_n])

order_file$main_cluster_n <- 0
order_file$main_cluster_n[my_main_cluster_ind_n] <- 1

#compute a new correction for only main cluster of the control
small_normal_fit <- lowess(main_cluster_n$gc_content,main_cluster_n$covN, lowess_f)
normal_fit4 <- approx(small_normal_fit$x, small_normal_fit$y, order_file$gc_content, rule=2)
normal_main_cluster_mean <- mean(main_cluster_n$covN)
normal_main_cluster_mean_vector <- matrix(normal_main_cluster_mean, length(order_file$gc_content))

###isolate main cluster in tumor sample

# modify call to the function defineMainCluster to return also the width of the main cluster
temp_main_cluster_t <- defineMainCluster(order_file$covT, tumor_fit)
my_main_cluster_ind_t <- temp_main_cluster_t$ind
my_main_cluster_width_t <-temp_main_cluster_t$width

main_cluster <- data.frame(covT = order_file$covT[my_main_cluster_ind_t], gc_content = order_file$gc_content[my_main_cluster_ind_t])

order_file$main_cluster_t <- 0
order_file$main_cluster_t[my_main_cluster_ind_t] <- 1

#compute a new correction for only main cluster of the tumor
small_tumor_fit <- lowess(main_cluster$gc_content,main_cluster$covT, lowess_f)
tumor_fit4 <- approx(small_tumor_fit$x,small_tumor_fit$y,order_file$gc_content, rule=2)
tumor_main_cluster_mean <- mean(main_cluster$covT)

#compute correction for gc bias by fits
order_file$corrected_covN4 <- (order_file$covN/normal_fit4$y)*(normal_main_cluster_mean/normal_mean)
order_file$corrected_covT4 <- (order_file$covT/tumor_fit4$y)*(tumor_main_cluster_mean/tumor_mean)
order_file$corrected_covR4 <- order_file$corrected_covT4/order_file$corrected_covN4

#now compute FWHM of the cluster by calling method
main_cluster_density_n <- density(order_file$corrected_covN4[my_main_cluster_ind_n], adjust=0.1,from=-1,to=10)
main_cluster_FWHM_data_n <- extractFWHM(main_cluster_density_n)
my_main_cluster_FWHM_n <-main_cluster_FWHM_data_n$FWHM
my_main_cluster_half_max_pos_right_n <-main_cluster_FWHM_data_n$half_max_pos_right
my_main_cluster_half_max_pos_left_n <-main_cluster_FWHM_data_n$half_max_pos_left
main_cluster_density_t <- density(order_file$corrected_covT4[my_main_cluster_ind_t], adjust=0.1,from=-1,to=10)
main_cluster_FWHM_data_t <- extractFWHM(main_cluster_density_t)
my_main_cluster_FWHM_t <-main_cluster_FWHM_data_t$FWHM
my_main_cluster_half_max_pos_right_t <-main_cluster_FWHM_data_t$half_max_pos_right
my_main_cluster_half_max_pos_left_t <-main_cluster_FWHM_data_t$half_max_pos_left

if ( writeGCcorrect_flag ==1 ){
	sub_order_file = order_file[ ,c("chromosome", "start", "corrected_covN4", "corrected_covT4", "corrected_covR4")]
	write.table( sub_order_file, paste0(plotDir,"all_seg.gc_corrected.txt") ,sep="\t", col.names=T, row.names=F, quote=F )
}

cat("correction for replication timing...\n")
order_file$tenkb <- order_file$start %/% 1000

rdWithTime <- merge(order_file, time10, by.x = c("chromosome", "tenkb"), by.y = c("chromosome", "tenkb"))

#compute correction for replication timing  by fits
order_file_rt <- rdWithTime[order(rdWithTime$time),]

#compute a new correction for only main cluster of the control
cat('fitting control...\n')
small_normal_fit_rt <- lowess(order_file_rt$time[order_file_rt$main_cluster_n==1], order_file_rt$corrected_covN4[order_file_rt$main_cluster_n==1], lowess_f)
normal_fit4_rt <- approx(small_normal_fit_rt$x,small_normal_fit_rt$y,order_file_rt$time, rule=2)
normal_main_cluster_mean_rt <- mean(main_cluster_n$covN)
normal_main_cluster_mean_rt_vector <- matrix(normal_main_cluster_mean_rt, length(order_file_rt$time))
#compute a new correction for only main cluster of the tumor
cat('fitting tumor...\n\n')
small_tumor_fit_rt <- lowess(order_file_rt$time[order_file_rt$main_cluster_t==1], order_file_rt$corrected_covT4[order_file_rt$main_cluster_t==1], lowess_f)
tumor_fit4_rt <- approx(small_tumor_fit_rt$x,small_tumor_fit_rt$y,order_file_rt$time, rule=2)
tumor_main_cluster_mean_rt <- mean(main_cluster$covT)
tumor_main_cluster_mean_rt_vector <- matrix(tumor_main_cluster_mean_rt, length(order_file_rt$time))

#compute correction for gc bias by fits ## remark Daniel: should be "compute correction for rt bias by fits"
order_file_rt$corrected_covN4_rt <- (order_file_rt$corrected_covN4/normal_fit4_rt$y)*(normal_main_cluster_mean_rt/normal_mean)
order_file_rt$corrected_covT4_rt <- (order_file_rt$corrected_covT4/tumor_fit4_rt$y)*(tumor_main_cluster_mean_rt/tumor_mean)
order_file_rt$corrected_covR4_rt <- (order_file_rt$corrected_covT4_rt)/(order_file_rt$corrected_covN4_rt)

##################
## start Daniel ##
##################

#compute fit to tcn ratio
ratio_fit  <- lowess(order_file_rt$gc_content,order_file_rt$corrected_covR4_rt, lowess_f)
#isolate main cluster in tcn ratio
temp_main_cluster <- defineMainCluster(order_file_rt$corrected_covR4_rt, ratio_fit)
ratio_main_cluster_ind <- temp_main_cluster$ind
ratio_main_cluster <- data.frame(covR = order_file_rt$corrected_covR4_rt[ratio_main_cluster_ind], gc_content = order_file_rt$gc_content[ratio_main_cluster_ind])
#establish density function on main cluster of tcn ratio
ratio_density <- density(ratio_main_cluster$covR, adjust=0.1,from=-1,to=10)
#compute FWHM of main cluster in tcn ratio
ratio_FWHM_data <- extractFWHM(ratio_density)
half_max_pos_right <- ratio_FWHM_data$half_max_pos_right
half_max_pos_left <- ratio_FWHM_data$half_max_pos_left
FWHM <- ratio_FWHM_data$FWHM
# #temporarily plot tcn ratio here
# matplot(order_file_rt$gc_content, order_file_rt$corrected_covR4_rt, type="p",pch=20,col="#00000022",ylim=c(0.0,3.0),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2))
# points(ratio_main_cluster$gc_content,ratio_main_cluster$covR, type='p', pch=20,col="red",cex=c(0.2,0.2) )
# plot(ratio_density,xlim=c(0,2))
# abline(v=max_pos,col="blue")
# abline(v=c(half_max_pos_left,half_max_pos_right),col="red")

#do quantitative characterization of GC bias correction
cat('do quantitative evaluation of GC bias correction:\n')
GC_correct_normal_lin <- lm(y~x,data=small_normal_fit)
GC_correct_tumor_lin <- lm(y~x,data=small_tumor_fit)
normal_table <- summary(GC_correct_normal_lin)$coefficients
tumor_table <- summary(GC_correct_tumor_lin)$coefficients
#compute slope (1st derivative) to estimate bias alternatively to linear regression (note that the x-values are equally spaced and allways the same, therefore one can compute the slope as Delta_y instead of Delta_y/Delta_x)
normal_slope <- diff(small_normal_fit$y)
mean_abs_normal_slope <- mean(abs(normal_slope))
mean_normal_slope <- mean(normal_slope)
tumor_slope <- diff(small_tumor_fit$y)
mean_abs_tumor_slope <- mean(abs(tumor_slope))
mean_tumor_slope <- mean(tumor_slope)
#compute curvature (2nd derivative) to estimate convexity of GC bias
normal_curvature <- diff(normal_slope)
mean_abs_normal_curvature <- mean(abs(normal_curvature))
mean_normal_curvature <- mean(normal_curvature)
tumor_curvature <- diff(tumor_slope)
mean_abs_tumor_curvature <- mean(abs(tumor_curvature))
mean_tumor_curvature <- mean(tumor_curvature)
#prepare for output
GCcorrectQuant_string <- paste(t(rbind(normal_table,tumor_table)),sep="\t")
#write to pid specific file
#return FWHM of tcn distribution in first two fields as quality est and param for clustering
write(c(pid,half_max_pos_left,half_max_pos_right,GCcorrectQuant_string,mean_normal_slope,mean_abs_normal_slope,mean_tumor_slope,mean_abs_tumor_slope,mean_normal_curvature,mean_abs_normal_curvature,mean_tumor_curvature,mean_abs_tumor_curvature,my_main_cluster_width_n,my_main_cluster_width_t,my_main_cluster_FWHM_n, my_main_cluster_FWHM_t),sep="\t",file=outGCcorrectQuant_file,ncolumns=31)

#do linear interpolation of replication time correction
cat('do linear regressions on rep time correction:\n')
#restrict fit for rep timing to 15 < reptime < 70 for fitting the slope 
normal_restriction_ind <- which(small_normal_fit_rt$x > 15 & small_normal_fit_rt$x < 70)
normal_model_fit_rt <- data.frame(x=small_normal_fit_rt$x[normal_restriction_ind],y=small_normal_fit_rt$y[normal_restriction_ind])
tumor_restriction_ind <- which(small_tumor_fit_rt$x > 15 & small_tumor_fit_rt$x < 70)
tumor_model_fit_rt <- data.frame(x=small_tumor_fit_rt$x[tumor_restriction_ind],y=small_tumor_fit_rt$y[tumor_restriction_ind])
if(restrict_flag){
  rep_time_correct_normal_lin <- lm(y~x,data=normal_model_fit_rt)
  rep_time_correct_tumor_lin <- lm(y~x,data=tumor_model_fit_rt) 
} else {
  rep_time_correct_normal_lin <- lm(y~x,data=small_normal_fit_rt)
  rep_time_correct_tumor_lin <- lm(y~x,data=small_tumor_fit_rt)  
}
summary(rep_time_correct_normal_lin)
normal_table <- summary(rep_time_correct_normal_lin)$coefficients
summary(rep_time_correct_tumor_lin)
tumor_table <- summary(rep_time_correct_tumor_lin)$coefficients
#prepare for output
repQuant_string <- paste(t(rbind(normal_table,tumor_table)),sep="\t")
#write to pid specific file
write(c(pid,repQuant_string),sep="\t",file=outrepQuant_file,ncolumns=17)

# ######################################################################################
# ## the following is OPTIONAL and might have to be refined when run in the pipeline! ##
# ######################################################################################
# 
# #write to overall GC bias correction file
# all_outGCcorrectQuant_file <- paste0("/home/huebschm/results/copy_number/repQuant/all_GCcorrect_quant.tsv")
# if (!file.exists(all_outGCcorrectQuant_file)) {
#   write(c("#pid","normal_intercept_estimate","normal_intercept_StdErr","normal_intercept_tVal","normal_intercept_pVal","normal_slope_estimate","normal_slope_StdErr","normal_slope_tVal","normal_slope_pVal","tumor_intercept_estimate","tumor_intercept_StdErr","tumor_intercept_tVal","tumor_intercept_pVal","tumor_slope_estimate","tumor_slope_StdErr","tumor_slope_tVal","tumor_slope_pVal","mean_normal_slope","mean_abs_normal_slope","mean_tumor_slope","mean_abs_tumor_slope","mean_normal_curvature","mean_abs_normal_curvature","mean_tumor_curvature","mean_abs_tumor_curvature","main_cluster_width_n","main_cluster_width_t"),sep="\t",file=all_outGCcorrectQuant_file,ncolumns=27)  
# }
# write(c(pid,GCcorrectQuant_string,mean_normal_slope,mean_abs_normal_slope,mean_tumor_slope,mean_abs_tumor_slope,mean_normal_curvature,mean_abs_normal_curvature,mean_tumor_curvature,mean_abs_tumor_curvature,my_main_cluster_width_n,my_main_cluster_width_t),sep="\t",file=all_outGCcorrectQuant_file,ncolumns=27,append=TRUE)
# 
# #write to overall rep timing correction file
# all_outrepQuant_file <- paste0("/home/huebschm/results/copy_number/repQuant/all_rep_quant.tsv")
# if (!file.exists(all_outrepQuant_file)) {
#   write(c("#pid","normal_intercept_estimate","normal_intercept_StdErr","normal_intercept_tVal","normal_intercept_pVal","normal_slope_estimate","normal_slope_StdErr","normal_slope_tVal","normal_slope_pVal","tumor_intercept_estimate","tumor_intercept_StdErr","tumor_intercept_tVal","tumor_intercept_pVal","tumor_slope_estimate","tumor_slope_StdErr","tumor_slope_tVal","tumor_slope_pVal"),sep="\t",file=all_outrepQuant_file,ncolumns=17)  
# }
# write(c(pid,repQuant_string),sep="\t",file=all_outrepQuant_file,ncolumns=17,append=TRUE)
# 
# ##########################
# ## end OPTIONAL section ##
# ##########################

################
## end Daniel ##
################

cat(paste0("writing results into ", outfile, "\n\n"))
out_table		<- order_file_rt[,c('chromosome', 'start', 'normal', 'tumor', 'covR', 'corrected_covR4_rt')]
colnames(out_table)	<- c('chromosome', 'start', 'normal', 'tumor', 'covR_raw', 'covR') 
out_table		<- out_table[order(out_table$chromosome, out_table$start),]

sub_order_file <- order_file_rt[,c('chromosome', 'start', 'corrected_covN4_rt', 'corrected_covT4_rt', 'corrected_covR4_rt')]
colnames(sub_order_file)  <- c('chromosome', 'start', 'covNnorm', 'covTnorm', 'covR') 
sub_order_file  	  <- sub_order_file[order(sub_order_file$chromosome, sub_order_file$start),]

#include Y chromosome without RT correction
sel_y_windows <- which(order_file$chromosome==24)
if(length(sel_y_windows)>0){
	y_windows 		<- order_file[sel_y_windows,]
	y_windows 		<- y_windows[,c("chromosome", "start", "normal", "tumor", "covR", "corrected_covR4")]
	colnames(y_windows)	<- c('chromosome', 'start', 'normal', 'tumor', 'covR_raw', 'covR') 
	y_windows 		<- y_windows[order(y_windows$chromosome, y_windows$start), ]
	out_table		<- rbind(out_table, y_windows)
  
	y_windows2  <- order_file[sel_y_windows,c("chromosome", "start", "corrected_covN4", "corrected_covT4", "corrected_covR4")]
	colnames(y_windows2)  <- c('chromosome', 'start', 'covNnorm', 'covTnorm', 'covR') 
	#y_windows2  <- order_file[,]
	sub_order_file <- rbind(sub_order_file,y_windows2)
}

#TODO: insert pdf here
#      filenames?
pdf( paste0(plotDir, "/", pid, "_qc_coverageDensityByChroomosome.pdf") )
  corCovInd <- which( colnames(sub_order_file) =="covNnorm" )
  diffPeaks <- checkControl( sub_order_file, corCovInd )
dev.off()

cat(diffPeaks, "\n")
if ( ! length(diffPeaks) == sum( is.na(diffPeaks) ) ) {
  sel <- paste( which( ! is.na( diffPeaks ) ), collapse=", " )
  bodyText <- paste0("Warning ", pid, ": Errors found for chromosome ", sel )
  system( paste0("echo ", bodyText," | mail -s ", pid, " ", email))
}

#create coverage and gc/replication-timing plots
if (plot_flag) {
  
  for( chr in unique(sub_order_file$chromosome) ) {
    selSub <- which(sub_order_file$chromosome==chr)
    sub <- sub_order_file[selSub,]
    
    chr <- gsub( 24, "Y", chr)
    chr <- gsub( 23, "X", chr)
    
    png(paste0(plotDir,"/control_", pid, "_chr", chr," _coverage.png"), width=2000, height=1000, type="cairo")
      plotCoverage( sub, chr=chr )
    dev.off()
  }
  
  #plot whole genome coverage
  coordinates <- adjustCoordinates( chrLengthTab, sub_order_file )
  newCoverageTab    <- coordinates$coverageTab
  chromosomeBorders <- coordinates$chromosomeBorders
  png(paste0(plotDir,"/control_", pid, "_wholeGenome _coverage.png"), width=2000, height=1000, type="cairo")
      plotCoverage( newCoverageTab, chromosomeBorders=chromosomeBorders )
  dev.off()

write.table(out_table, outfile, row.names=FALSE, col.names=TRUE,sep='\t', quote=F)
write.table(sub_order_file, paste0(plotDir,"/all_corrected.txt"), row.names=FALSE, col.names=TRUE,sep='\t', quote=F)

cat("creating plots...\n\n")
png(file=outputfile_gc, width=1000, height=2000, type='cairo')
	par(mfrow=c(4,3))

	##plot raw data
	#control raw
	matplot(order_file$gc_content,order_file$covN,type="p",pch=20,col="#0000FF22",xlim=c(0.28,0.71), ylim=c(quantile(file_comb$covN,0.01),quantile(file_comb$covN,0.999)),xlab="%GC",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	points(main_cluster_n$gc_content,main_cluster_n$covN, type='p', pch=20,col="red",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	lines(normal_fit$x,normal_fit$y)
	lines(normal_fit4$x,normal_fit4$y, col='blue')
	lines(normal_fit$x,0.5*normal_fit$y)
	lines(normal_fit$x,normal_mean_vector,col="red")

	#tumor raw
	matplot(order_file$gc_content,order_file$covT, type='p', pch=20,col="#FFA50022",xlim=c(0.28,0.71),ylim=c(quantile(file_comb$covT,0.01), quantile(file_comb$covT,0.999)), xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	points(main_cluster$gc_content,main_cluster$covT, type='p', pch=20,col="red",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2) )
	lines(tumor_fit$x,tumor_fit$y)
	lines(tumor_fit4$x,tumor_fit4$y, col='blue')
	lines(tumor_fit4$x,0.5*tumor_fit4$y)
	lines(tumor_fit4$x,1.5*tumor_fit4$y)
	lines(tumor_fit$x,tumor_mean_vector,col="red")
	#coverage ratio raw
	matplot(order_file$gc_content,order_file$covR,type="p",pch=20,col="#00000022",ylim=c(0,3),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2))

	##plot corrected data (using all data points to fit curve)
	matplot(order_file$gc_content,order_file$corrected_covN,type="p",pch=20,col="#0000FF22",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	matplot(order_file$gc_content,order_file$corrected_covT, type='p', pch=20,col="#FFA50022",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	matplot(order_file$gc_content,order_file$corrected_covR,type="p",pch=20,col="#00000022",ylim=c(0,3),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2))  

	#plot corrected graphs (curves fitted to main cloud)
	matplot(order_file$gc_content,order_file$corrected_covN4,type="p",pch=20,col="#0000FF22",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	matplot(order_file$gc_content,order_file$corrected_covT4, type='p', pch=20,col="#FFA50022",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))  
	matplot(order_file$gc_content,order_file$corrected_covR4,type="p",pch=20,col="#00000022",ylim=c(0,3),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized log ratio",main=paste(pid, "log Ratio", sep=" "),cex=c(0.2,0.2))  

	#plot corrected plots with replication timing correction
	matplot(order_file_rt$gc_content, order_file_rt$corrected_covN4_rt, type="p",pch=20,col="#0000FF22",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	abline(h=c(0.5,1,1.5))
	matplot(order_file_rt$gc_content, order_file_rt$corrected_covT4_rt, type="p",pch=20,col="#FFA50022",ylim=c(0.1,2.2),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	abline(h=c(0.5,1,1.5))
	matplot(order_file_rt$gc_content, order_file_rt$corrected_covR4_rt, type="p",pch=20,col="#00000022",ylim=c(0.0,3.0),xlim=c(0.28,0.71),xlab="%GC",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2)) 
  points(ratio_main_cluster$gc_content,ratio_main_cluster$covR, type='p', pch=20,col="red",cex=c(0.2,0.2) )

dev.off()

png(file=outputfile_rep, width=1000, height=1500, type='cairo')
	par(mfrow=c(3,3))
	#plot uncorrected curves replication timing
	matplot(order_file_rt[,"time"],order_file_rt$covN,type="p",pch=20,col="#0000FF22",ylim=c(quantile(file_comb$covN,0.01),quantile(file_comb$covN,0.999)), xlim=c(0,80),xlab="time",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	matplot(order_file_rt[,"time"],order_file_rt$covT,type="p",pch=20,col="#FFA50022",ylim=c(quantile(file_comb$covN,0.01),quantile(file_comb$covN,0.999)), xlim=c(0,80),xlab="time",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	matplot(order_file_rt[,"time"],order_file_rt$covR,type="p",pch=20,col="#00000022",ylim=c(0,3),xlim=c(0,80),xlab="time",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2))

	#replication timing and gc corrected values
	#control
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covN4,type="p",pch=20,col="#0000FF22",ylim=c(0.1,2.2),xlim=c(0,80),xlab="time",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	points(order_file_rt[order_file_rt$main_cluster_n==1,"time"], order_file_rt$corrected_covN4[order_file_rt$main_cluster_n==1],pch=20,col="red",cex=c(0.2,0.2))
	lines(normal_fit4_rt$x,normal_fit4_rt$y, col='blue')
	lines(normal_fit4_rt$x,0.5*normal_fit4_rt$y)
	lines(normal_fit4_rt$x,1.5*normal_fit4_rt$y)
	lines(normal_fit4_rt$x,normal_main_cluster_mean_rt_vector, col="red")      
	#tumor
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covT4,type="p",pch=20,col="#FFA50022",ylim=c(0.1,2.2), xlim=c(0,80),xlab="time",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	points(order_file_rt[order_file_rt$main_cluster_t==1,"time"], order_file_rt$corrected_covT4[order_file_rt$main_cluster_t==1],cex=c(0.2,0.2), col='red')
	lines(tumor_fit4_rt$x,tumor_fit4_rt$y, col='blue')
	lines(tumor_fit4_rt$x,0.5*tumor_fit4_rt$y)
	lines(tumor_fit4_rt$x,1.5*tumor_fit4_rt$y)
	lines(tumor_fit4_rt$x,tumor_main_cluster_mean_rt_vector,col="red")
	#coverage ratio
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covR4,type="p",pch=20,col="#00000022",ylim=c(0,3),xlim=c(0,80),xlab="time",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2)) 
	abline(h=c(1), col='red')

	#plot corrected plots      
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covN4_rt,type="p",pch=20,col="#0000FF22", ylim=c(0.1,2.2), xlim=c(0,80), xlab="time",ylab="normalized reads",main=paste(pid, "control", sep=" "),cex=c(0.2,0.2))
	abline(h=c(0.5,1,1.5))
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covT4_rt,type="p",pch=20,col="#FFA50022", ylim=c(0.1,2.2), xlim=c(0,80), xlab="time",ylab="normalized reads",main=paste(pid, "tumor", sep=" "),cex=c(0.2,0.2))
	abline(h=c(0.5,1,1.5))
	matplot(order_file_rt[,"time"],order_file_rt$corrected_covR4_rt,type="p",pch=20,col="#00000022", ylim=c(0.0,3.0), xlim=c(0,80), xlab="time",ylab="normalized coverage ratio",main=paste(pid, "coverage Ratio", sep=" "),cex=c(0.2,0.2)) 
	abline(h=c(1), col='red')

dev.off()

}
