#!/usr/bin/env python

# Copyright (c) 2017 The ACEseq workflow developers.
# Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

####### Kortine Kleinheinz
####### 8.01.2013
## Adjust counts for allele frequencies based on imputation results 
## A-allele considererd allele of genotype in first position
## e.g for genotype 1|0 A-allele: Alt-freq B-allele: REF-freq

import argparse
import gzip
import sys
import subprocess

from python_modules import Tabfile

parser=argparse.ArgumentParser(description = "Add phased haplotypes")
parser.add_argument('--inputsuffix', '-i', type = str, help = "suffix of vcf file with phased genotypes")
parser.add_argument('--inputpath', '-p', type = str, help = "path and prefix to vcf file with phased genotypes")
parser.add_argument('--out', '-o', default=sys.stdout, help = "Output file. Default: STDOUT")
parser.add_argument('--snps', '-s', default="", type = str, help = 'File containing SNP information with allele frequencies')
args = parser.parse_args()

if not args.inputpath or not args.inputsuffix:
	sys.stderr.write("Please specify input and SNP file. For more information use -h\n")
	sys.exit(2)	

if not args.snps:
	args.snps=""

out=args.out

if args.out != sys.stdout:
	try:
		out   = subprocess.Popen("bgzip >%s"% args.out, shell=True, stdin=subprocess.PIPE)
	except IOError as (errno, strerr):
		sys.stderr.write( "IOError %i: %s\n"% (errno, strerr) )
		sys.exit(errno)
	
try:
	snpFile = Tabfile.Input( gzip.open( args.snps ) )
except IOError as (errno, strerr):
	try:
		snpFile = Tabfile.Input( sys.stdin )
	except IOError:
		sys.stderr.write( "IOError %i: %s\n"% (errno, strerr) )
		sys.exit(errno)

curr_chrom = ''

for line in snpFile:
	chrom = line['chr']
	if chrom.startswith('chr'):
		chrom = chrom.replace('chr', '')
		line['chr'] = line['chr'].replace('chr', '')
	pos   = int( line['startPos'] )
	line['haplotype'] = 0
	
	if chrom != curr_chrom:
		try:
			infile     = Tabfile.Input( open( "%s%s%s"% (args.inputpath, chrom, args.inputsuffix) ) )
#			sample_col = [a for a in infile.header if a.startswith('sample')][0]			# name of column with sample information
			sample_col = infile.header[len(infile.header)-1] #last column in vcf file 
			gt_pos     = 0
			genotype   = 'xxx'

		except IOError as (errno, strerr):
			if int(chrom) < 24:
				sys.stderr.write( "IOError %i: %s"% (errno, strerr) )
				sys.exit(errno)
		curr_chrom = chrom
		
	while ( pos > gt_pos ):

		genotype = infile.readline()
		if genotype == None:
			break
		genotype['CHROM']= genotype['CHROM'].replace('chr', '')
		gt_pos = int( genotype['POS'] )
		
	if gt_pos == pos and genotype and genotype['CHROM'] == curr_chrom:
		genotype_field = genotype['FORMAT'].split(":")
		genotype_pos   = genotype_field.index("GT")
		sample_line    = genotype[sample_col].split(":")
		phase          = sample_line[genotype_pos][1] == '|'
		gt_alt         = sample_line[genotype_pos][0] == '1'

		if phase:
			line['haplotype'] = 1									# phased genotype found
			if gt_alt:										# genotype in first position is not reference base
				line['haplotype'] = 2
				line['Anormal'], line['Bnormal'] = line['Bnormal'], line['Anormal']
				line['Atumor'] , line['Btumor']  = line['Btumor'] , line['Atumor']
		
	out.stdin.write( "%s\t%s\t%s\t%s\t%s\t%s\t%i\n"% ( line["chr"], pos, line["Anormal"], line["Bnormal" ], line["Atumor" ], line["Btumor"], line['haplotype'] ) )

out.communicate()
