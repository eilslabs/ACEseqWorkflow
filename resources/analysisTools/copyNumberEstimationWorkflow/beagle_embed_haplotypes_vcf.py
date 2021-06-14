#!/usr/bin/python
import argparse
import gzip

def is_comment_line(line):
    return line.startswith("#")

parser = argparse.ArgumentParser()
parser.add_argument('--hap_file', help='Input file with phased haplotypes (i.e. output from Beagle)')
parser.add_argument('--vcf_file', help='Input .vcf file')
parser.add_argument('--out_file', help='Out .vcf file')
args = parser.parse_args()

if args.hap_file.split('.')[-1] == 'gz':
    hap_file = gzip.open( args.hap_file, "r" )
else:
    hap_file = open( args.hap_file, "r" )
vcf_file = open( args.vcf_file, "r" )
outfile = open( args.out_file, "w" )

hap_line = hap_file.readline()
while is_comment_line(hap_line):
    hap_line = hap_file.readline()

if hap_line:
    hap_line = hap_line.rstrip().split()

for vcf_line in vcf_file:
    
    if not is_comment_line(vcf_line):
        
        vcf_line = vcf_line.rstrip().split("\t")
        vcf_line[0] = vcf_line[0].replace('chr', '')
        vcf_line[0] = vcf_line[0].replace( 'X', '23' )

        if len(vcf_line) >= 9 and hap_line:
            
            while hap_line and int(hap_line[1]) < int(vcf_line[1]):
                hap_line = hap_file.readline()
                
                if hap_line:
                    hap_line = hap_line.rstrip().split()
                    
            if hap_line and int(hap_line[1]) == int(vcf_line[1]):
                
                format_field = hap_line[8].split(":")
                genotype_pos_hap = format_field.index( "GT" )
                format_field = vcf_line[8].split(":")
                genotype_pos_vcf = format_field.index( "GT" )
                vcf_line[9] = vcf_line[9].split(":")

                vcf_line[9][genotype_pos_vcf] = hap_line[9].split(":")[genotype_pos_hap]
                vcf_line[9] = ":".join( vcf_line[9] )
                
        vcf_line = "\t".join( vcf_line )+"\n"
        
    outfile.write( vcf_line )
