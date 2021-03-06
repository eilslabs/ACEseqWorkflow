#!/usr/bin/R

# Copyright (c) 2017 The ACEseq workflow developers.
# This script is licenced under (license terms are at
# https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

library(getopt)
script_dir = dirname(get_Rscript_filename())

#source(paste0(script_dir, "/getopt.R"))

spec <- matrix(c(
  "fileGoodControl", "f", "1", "character", #"file with good control values",
  "fileBadControl",  "b", "1", "character", #"file with bad control values",
  "out",             "o", "1", "character"  #"combined file with path"
  ), byrow=TRUE, ncol=4  )

opt = getopt(spec);
for(item in names(opt)){
       assign( item, opt[[item]])
}

tabGoodControl <- read.table(fileGoodControl)
tabBadControl <- read.table(fileBadControl)
colNames <- c("chr", "pos", "end", "control", "tumor", "map")
colnames(tabGoodControl) <- colNames
colnames(tabBadControl) <- colNames


merged <- merge(tabGoodControl, tabBadControl, by=c("chr","pos"),all.x=F, all.y=F )
submerged <- merged[, c("chr", "pos", "end.y", "control.x", "tumor.y", "map.y" )]

submerged <- submerged[order(submerged$chr, submerged$pos),]
colnames(submerged) <- c("#chr", "pos", "end", "normal", "tumor", "map")
write.table(submerged, pipe( paste0("gzip >",out) ), quote=F, row.names=F, col.names=T, sep="\t")
