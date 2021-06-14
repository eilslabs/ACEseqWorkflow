#!/usr/bin/python

import argparse

def is_comment_line(line):
    return line.startswith("#")

parser = argparse.ArgumentParser()
parser.add_argument('--in_file', help='Input .vcf file')
parser.add_argument('--out_file', help='Out .vcf file')
args = parser.parse_args()

vcf_infile = open( args.in_file, "r" )
outfile    = open( args.out_file, "w" )

for vcf_line in vcf_infile:
    
    if is_comment_line(vcf_line):
        if vcf_line.startswith("#CHROM"):
            vcf_line = vcf_line.rstrip().split("\t")
            vcf_line.append('sample0')
            vcf_line = "\t".join( vcf_line )+"\n"

    else:
        vcf_line = vcf_line.rstrip().split("\t")
        vcf_line.append(vcf_line[9])
        vcf_line = "\t".join( vcf_line )+"\n"

    outfile.write( vcf_line )
