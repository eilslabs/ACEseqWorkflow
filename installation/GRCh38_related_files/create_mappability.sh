#!/bin/bash

nr_cores=4
kmer=100
reference_genome="${reference_path}/GRCh38_decoy_ebv_phiX_alt_hla_chr.fa"

mkdir -p ref out
# copy the reference but only chr1-22, X and Y
echo "copy reference genome"
awk '/^>chrM/ {exit} /^>/ {print $1}  !/^>/ {print}' ${reference_genome} > ref/reference.fa
echo "gem-indexer"
./tools/gem-indexer -T ${nr_cores} -c dna -i ref/reference.fa -o out/index
echo "gem-mappability"
./tools/gem-mappability -T ${nr_cores} -I out/index.gem -l ${kmer} -o out/outfiles
echo "gem-2-wig"
./tools/gem-2-wig -I out/index.gem -i out/outfiles.mappability -o out/outfiles
echo "wigToBigWig"
./tools/wigToBigWig out/outfiles.wig out/outfiles.sizes out/outfiles.bigWig
echo "bigWigToBedGraph"
./tools/bigWigToBedGraph out/outfiles.bigWig out/outfiles.bedGraph

echo "Filter lines and compress"
awk '$4 > 0.0 {print $0}' out/outfiles.bedGraph | ./tools/bgzip > GRCh38_Mappability_Align_100mer.bedGraph.gz

echo "Create Index with Tabix"
./tools/tabix -p bed GRCh38_Mappability_Align_100mer.bedGraph.gz

echo "cleaning"
rm -r ref out
