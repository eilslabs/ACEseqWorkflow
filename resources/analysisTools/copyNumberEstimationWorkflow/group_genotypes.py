#!/usr/bin/env python

# Copyright (c) 2017 The ACEseq workflow developers.
# Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

##Kortine Kleinheinz
## 8.01.2013
## Group haplotype Blocks obtained with imputation
## a haplotype group start at first phased SNP after an unphased SNP and is ended with the next occuring unphased SNP

import argparse
import sys

from python_modules import Tabfile

parser=argparse.ArgumentParser(description = "Group phased haplotypes")
parser.add_argument('--infile', '-i', type = file, help = "vcf file with phased genotypes")
parser.add_argument('--out', '-o', help = "Output file. Default: STDOUT")
parser.add_argument('--minHT', '-m', type = int, default = 5, help = 'Minimum number of phased haplotypes for segment to be considered. Default=5')
args = parser.parse_args()

if args.out:
	out = open(args.out, 'w')
else:
	out = sys.stdout

if not args.infile:
	print sys.stderr.write("Please specify input file. For more information use -h")


infile= Tabfile.Input( args.infile )
#sample_col = [a for a in infile.header if a.startswith('sample')][0]	#name of  column with sample information
sample_col = infile.header[len(infile.header)-1] #last column in vcf file 

count = 0
ggroup = 0
genotypes = []

for line in infile:
	
	genotype_field = line['FORMAT'].split(":")
	genotype_pos   = genotype_field.index("GT")
	sample_line = line[sample_col].split(":")
	phase = sample_line[genotype_pos][1] == '|'
	
	if ggroup and not phase: 				#end of haplotype block
		if len(genotypes) >= args.minHT:		#minimum number of phased haplotypes fullfilled?
			start  = int(genotypes[0]['POS'])
			end    = int(genotypes[-1]['POS'])
			length = end - start + 1 
			out.write('%s\t%i\t%i\t%i\n'% (genotypes[0]['CHROM'], start, end, length)	)	
		genotypes = []
		ggroup = 0

	elif phase:
		ggroup=1
		genotypes.append(line)
