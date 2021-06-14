#!/bin/bash

module load java/1.8.0_131 

for chr in `seq 1 22` X Y
do
  echo $chr
  (zcat ALL.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz | head -n 300 | grep "#" ; zcat ALL.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz | grep -v "#" | sed 's/^/chr/') | java -jar bref3.18May20.d20.jar > ALL.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.CHR.bref
done
