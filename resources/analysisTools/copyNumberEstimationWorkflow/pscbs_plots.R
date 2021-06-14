#!/usr/bin/R

# Copyright (c) 2017 The ACEseq workflow developers.
# This script is licenced under (license terms are at
# https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

library(getopt)
script_dir = dirname(get_Rscript_filename())


spec <- matrix(c('SNPfile',       'f', 1, "character", 
                 'svFile',     	  'c', 1, "character",
                 'segments',      's', 1, "character", 
                 'outfile',       'o', 1, "character", 
                 'chrLengthFile', 'l', 1, "character", 
                 'pp',            'p', 1, "character", 
                 'outDir',        'x', 1, "character", 
                 'file_sex',      'g', 1, "character", 
                 'sv_YN',         'y', 1, "character", 
                 'ID',            'i', 1, "character", 
				 'pipelineDir',	  'd', 1, "character",
				 'ymaxcov_threshold', 't', 1, "numeric"
                ), ncol = 4, byrow = TRUE)
               
 
opt = getopt(spec);
for(item in names(opt)){
       assign( item, opt[[item]])
}
 
cat(paste0("SNPfile: ", SNPfile, "\n\n"))
cat(paste0("sv: ", svFile, "\n\n"))
cat(paste0("segments: ", segments, "\n\n"))
cat(paste0("outfile: ", outfile, "\n\n"))
cat(paste0("chrLengthFile: ", chrLengthFile, "\n\n"))
cat(paste0("pp: ", pp, "\n\n"))
cat(paste0("outDir: ", outDir, "\n\n"))
cat(paste0("file_sex: ", file_sex, "\n\n"))
cat(paste0("sv_YN: ", sv_YN, "\n\n"))
cat(paste0("ID: ", ID, "\n\n"))
cat(paste0("pipelineDir: ", pipelineDir, "\n\n"))
cat(paste0("ymaxcov_threshold: ", ymaxcov_threshold, "\n\n"))
cat("\n")

source( file.path(pipelineDir, "pscbs_plots_functions.R") )
source( file.path(pipelineDir, "annotateCNA.R") )
source( file.path(pipelineDir, "correctGCBias_functions.R") ) # for adjustCoordinates()

cat("reading \n\n")

#read data and set variables
if (sv_YN == "true") {
	sv <- try( read.table(svFile, sep = "\t", header = FALSE, as.is = TRUE, stringsAsFactors = TRUE)[1:6], silent=TRUE )
	if ( is.data.frame(sv) ){
		colnames(sv) = c("chromosome", "start", "end", "length", "type", "chr2")
		svAll = data.frame(sv)
	}else{
		sv=NULL
	}
	
}else{
	sv = NULL
}

segments = read.table(segments, sep = "\t", header = TRUE, as.is = TRUE, stringsAsFactors = TRUE)
segAll = data.frame(segments) 
combi = segAll 
	  
chr = read.table(chrLengthFile, header = FALSE, as.is = TRUE)
chrLength = data.frame(chr)
chrLength$V1 <- gsub('chr','',chrLength$V1)

sel = which(chrLength$V1 == "X")
chrLength$V1[sel] = 23
sel = which(chrLength$V1 == "Y")
chrLength$V1[sel] = 24
                
sex = read.table(file_sex, header=FALSE, stringsAsFactors=FALSE)[,1]
if (sex == "male" | sex == 'klinefelter') {
	chromosomes = c(1:24)
	chrCount = 24
	chrNames = c(1:22, 'X','Y')
} else if (sex == "female") {
	chromosomes = c(1:23)
	chrCount = 23
	chrNames = c(1:22, 'X')
}
                
pp = read.table(pp, sep = "\t", header = TRUE, as.is = TRUE, stringsAsFactors = TRUE) # pp stands for ploidy and tcc
full_Ploidies = pp[, 1]		#rounded ploidy values
 
maxChrCount <- max( as.numeric( system( paste( "tabix -l", SNPfile ) ,intern=TRUE ) ) ) 
if (chrCount > maxChrCount) {
	cat("Warning: maxChrCount is not equal to chrCount, possible loss of chromosome!!\n")
#	chrCount <- maxChrCount
}


#function wrappers to get chromosome wise plots of TCN, dh and BAF
plotChromosomes = function (chrom, dat, comb,  TCC, ploi , roundPloi, svPoints=NULL, secondChoicePloidyFilnameAddition="") {
	#don't plot if data frame is empty
	if (nrow(dat)<1)
		return(NULL)
	
	ratio=dat
  
	sel  = which( comb$chromosome == chrom )
	segs = comb[sel,]

	if ( is.data.frame(svPoints) ){	
		sel 	 = which(svPoints$chromosome==chrom)
		svSub = svPoints[sel,]
	}else{
		svSub = NULL
	}
	sel = which(chrLength$V1==chrom)
	chrL <- chrLength$V2[sel]

#	maxCov = 2*ploi
	maxCov = max(comb$tcnMean, na.rm= TRUE)

	p1 <- plotTCN( chrom, ratio, segs, ploi, TCC, roundPloi, chrL, ymaxcov=maxCov, svSub=svSub, ymaxcov_threshold=ymaxcov_threshold) + labs(x=NULL)
	p2 <- plotDHmeans( segs, chrL ) + theme( axis.text.x=element_blank() )

	X = which( (ratio$betaN > 0.3) & (ratio$betaN < 0.7) )
	p3 <- plotRawBAF( ratio[X,], seg=segs, chrL ) 

  plotTitle <- textGrob( paste0("",ID, "_chr_",chrom, " Ploidy=",roundPloi, ", corr=",round(ploi,digits=3), ", Tumor_cell_content=",round(TCC,digits=3), "") )
  p = arrangeGrob(plotTitle, p1, p2, p3, nrow=4, heights=c(1,7,7,7))

	fileName=paste0(outfile,"_",round(ploi,digits=3),"extra_",round(TCC,digits=3),"_",chrom,secondChoicePloidyFilnameAddition,".png")
        ggplot2::ggsave( fileName, p, width=15, height=9, type='cairo') 

}  


#function wrapper to get genome wide plot of TCN, dh and BAF
plotAll <- function(dat, comb, ploi, TCC, roundPloi, chrCount, secondChoicePloidyFilnameAddition="", index) {
				
	chrL = sum( as.numeric(chrLength[1:chrCount,2]) )
#	maxCov = 3*ploidy
	maxCov = max(comb$tcnMean, na.rm=TRUE)
	
	xoff  = 0
	xoffsets = xoff
	xtot = chrL/10
       
	#adjust coordinates so plots can be made from single dataframe with single command
	for ( chr in seq_len(chrCount) ) {
			
		sel = which(comb$chromosome==chr)
		comb$start[sel] <- comb$start[sel]+xoff
		comb$end[sel]   <- comb$end[sel]+xoff

		#division by 10 done in function		
		dat[[chr]]$start <- dat[[chr]]$start+xoff
		dat[[chr]]$end   <- dat[[chr]]$end+xoff
		dat[[chr]]$SNP   <- dat[[chr]]$SNP+xoff

		xoff = xoff + chrLength[chrLength$V1==chr,2] 
		xoffsets = append( xoffsets, xoff/10 )
	}
	#combine lists into single data.frame to 
	dat <- do.call(rbind, dat)
	gc()

	dat <- dat[,c('start', 'end', 'SNP', 'betaT', 'betaN', 'copyT', 'GNL', 'haplotype' )]
	X = which((dat$betaN > 0.3) & (dat$betaN < 0.7))

	#plot
	p1 <- plotTCN( chr, dat, comb, ploi, TCC, roundPloi, chrL, maxCov, plots='all', ymaxcov_threshold=ymaxcov_threshold )
	p2 <- plotDHmeans( comb, chrL, plots='all' )
	p3 <- plotRawBAF( dat[X,], comb, chrL, plots='all' )

	#limit plots to TCN [ymaxcov_threshold] to avoid displaying high level amplifications
	if (maxCov>ymaxcov_threshold+2){
		maxCov = ymaxcov_threshold
	}

	#add chromosome labels and borders
	labels.data 	   <- data.frame(xPos=chrLength[1:chrCount,2] / 20 + xoffsets[1:length(xoffsets) -1] )
	labels.data$xPos   <- labels.data$xPos/xtot
	labels.data$maxCov <- replicate(nrow(labels.data), maxCov)
	labels.data$chr    <- as.character(chrNames)

	hlinesDH <- geom_hline( yintercept= c(0, 0.2, 0.4, 0.6, 0.8, 1), col="lightgray", lty="dotted", lwd=0.4)
	vlines   <- geom_vline( xintercept= xoffsets[2:length(xoffsets)]/xtot, col="#000000", lwd = 0.2 )

	p1 <- p1 + geom_hline( yintercept=seq(0, maxCov+0.8, 1), col='lightgray', lty='dotted', lwd=0.4 )
	p1 <- p1 + vlines + labs(x=NULL) + theme( axis.text.x=element_blank() )
	p1 <- p1 + geom_text( data=labels.data,aes( x=xPos, y=maxCov+0.8, label=chr), size=5 ) 

	p2 <- p2 + hlinesDH 
	p2 <- p2 + vlines + theme( axis.text.x=element_blank() )
		          
	p3 <- p3 + hlinesDH
	p3 <- p3 + vlines + labs(x=NULL) + theme( axis.text.x=element_blank() )

	#combine all plots into single object and save
	plotTitle <- textGrob( paste0("",ID, "_Ploidy=",roundPloi, ", corr=",round(ploi,digits=3), ", Tumor_cell_content=",round(TCC,digits=3), ", sex=",sex, ""))
	p = arrangeGrob(plotTitle, p1, p2, p3, nrow=4, heights=c(1,7,7,7))

	fileName= paste0( outfile, "_", round(ploi,digits=3), "_", round(TCC,digits=3), "_ALL", secondChoicePloidyFilnameAddition, ".png" )
        ggplot2::ggsave( fileName, p, width=15, height=9, type='cairo')



  if (index == 1) {
    # Plot combined 'coverage' and 'rawBAF' (only once, not the same plot for all pp solutions)
    chrLengthTab = chrLength
    colnames(chrLengthTab)[1:2]  <- c("chromosome", "length")
    chrLengthTab$chromosome <- as.numeric(chrLengthTab$chromosome)
    chrLengthTab <- chrLengthTab[order(chrLengthTab$chromosome),]
    plotDir = paste0(outDir,"/plots")
    sub_order_file = read.table(file = paste0(plotDir,"/all_corrected.txt.gz"), sep="\t", header = T)
    
    coordinates <- adjustCoordinates( chrLengthTab, sub_order_file )
    coverageTab <- coordinates$coverageTab
    chromosomeBorders <- coordinates$chromosomeBorders
    
    coverageTab = coverageTab[coverageTab$chromosome %in% seq(chrCount),]
    coverageTab$start = coverageTab$start/1000000
    
    coveragePlot = ggplot( coverageTab, aes(start, log2(covR) ) )  +
      geom_point(size=0.1) +
      geom_text( data=labels.data, aes( x=xPos*max(coverageTab$start), y=3.8, label=chr),size=4 ) +
      geom_hline(yintercept=c(-4,-3,-2,-1,1,2,3,4), col="#C0C0C0", lty="dotted", lwd=0.7) +
      geom_hline(yintercept=0, col="red", lwd=0.6) +
      geom_vline( xintercept= chromosomeBorders[seq(chrCount)+1]/1000000, col="#000000", lwd = 0.2 ) +
      xlab("genomic coordinate (MB)") + ylab("log2 corrected normalized coverage ratio") +
      ylim(c(-4,4)) + theme_bw()  +
      theme( axis.title = element_text(size=9), legend.position="none", panel.grid=element_blank(), panel.background=element_blank(), panel.margin=unit(c(0,0,0,0), 'mm') )
    
    plotTitle <- textGrob( paste0(ID,", sex=",sex, ""))
    p = arrangeGrob(plotTitle, coveragePlot, p3, nrow=3, heights=c(1,7,7))
    fileName= paste0( outfile, "_CovBaf.png" )
    ggplot2::ggsave( fileName, p, width=15, height=7, type='cairo')
  }

}

#read and complete SNP data and segments and create plots
colNamesData <- c( "chromosome", "SNP", "start", "end", "SV.Type", "copyT", "covT", "meanTCN", "betaT","betaN", "Atumor", "Btumor", "Anormal", "Bnormal", "haplotype", "map" )


dataList = lapply( 1:chrCount, function(chr){
	cat( "Reading chr ", chr," from ", SNPfile, "...\n" )
	dataList.chr <- try( read.table( pipe( paste( "tabix", SNPfile, chr ) ), header=FALSE, sep='\t' ), silent=TRUE )
	if ( is.data.frame(dataList.chr)  ) {
		colnames( dataList.chr ) = colNamesData
		return(dataList.chr)
	} else {
		cat(chr," not found in ", SNPfile, "skipping!\n")
		return(data.frame( matrix(vector(), 0, length(colNamesData), dimnames=list(c(), colNamesData)), stringsAsFactors=F))
	}
})


for( index in seq_len( nrow(pp) ) ) {
  cat(paste0("plotting ",index, "/",nrow(pp), "\n\n"))

  ploidy      = pp[index, 2]
  tcc      = pp[index, 3]

  #Read and complete data; get chromsome wise and genome wide plot
  tmp.list <- completeSeg( combi, ploidy, tcc, ID, solutionPossible=nrow(pp), sex=sex )
  lapply(seq_along(tmp.list), function(i) {
    secondChoicePloidyFilnameAddition = ""
    tmp = tmp.list[[i]]
    combi.tmp <- tmp[[1]]
    roundPloidy = tmp[[2]]
    if (i>1) {
      cat("Processing second choice fullPloidy...\n")
      secondChoicePloidyFilnameAddition = paste0(".fullPloidy",roundPloidy)
    }

    dataList.tmp = lapply( 1:chrCount, function(chr){
      cat("Plotting chromosome ",chr, "...\n")
      dataList.chr <- completeSNP( chr, dataList[[chr]], ploidy, tcc, roundPloidy)
      plotChromosomes( chr, dataList.chr, combi.tmp, tcc, ploidy, roundPloidy, svPoints=sv)
      return(dataList.chr)
    } )

    gc()
    cat("plotting All chromosomes...\n")

    #genome wide plot
    plotAll(dataList.tmp, comb=combi.tmp, ploidy, tcc, roundPloidy, chrCount, index=index)
    #remove tmp data.frame to free memory and use garbage collection
    dataList.tmp <- NULL
    tmp <- NULL

    gc()
  })

}
