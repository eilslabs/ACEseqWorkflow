#!/usr/bin/python

# Copyright (c) 2017 The ACEseq workflow developers.
# Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

from python_modules import Options

def is_comment_line(line):
    return line.startswith("#")

options = Options.parse( { "hap_file" : str, "vcf_file" : str,
                           "outfile"  : str  } )
if options:

	hap_infile = open( options["hap_file"], "r" )
	vcf_infile = open( options["vcf_file"], "r" )
	outfile    = open( options["outfile" ], "w" )

	haplo_line = hap_infile.readline()
	
	if haplo_line:
		haplo_line = haplo_line.rstrip().split()
	
	for vcf_line in vcf_infile:
		
		if not is_comment_line(vcf_line):
			
			vcf_line = vcf_line.rstrip().split("\t")
			vcf_line[0] = vcf_line[0].replace('chr', '')
			vcf_line[0] = vcf_line[0].replace( 'X', '23' )

			if len(vcf_line) >= 9 and haplo_line:
				
				while haplo_line and int(haplo_line[2]) < int(vcf_line[1]):
					haplo_line = hap_infile.readline()
					
					if haplo_line:
						haplo_line = haplo_line.rstrip().split()
						
				if haplo_line and int(haplo_line[2]) == int(vcf_line[1]):
					
					format_field = vcf_line[8].split(":")
					genotype_pos = format_field.index( "GT" )
					vcf_line[9] = vcf_line[9].split(":")
					vcf_line[9][genotype_pos] = haplo_line[5]+"|"+haplo_line[6]
					vcf_line[9] = ":".join( vcf_line[9] )
					
			vcf_line = "\t".join( vcf_line )+"\n"
			
		outfile.write( vcf_line )
