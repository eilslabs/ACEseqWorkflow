### Reference files for GRCh38

Information on downloading and parsing files needed for GRCh38 reference genome


#### Reference genome

We are using the GRCh38 version hosted at `http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa`,

The above reference genome (GRCh38_decoy_ebv_phiX_alt_hla) can be downloaded and processed using the repositiry at `https://github.com/DKFZ-ODCF/setup-reference-data`.

List of files needed from the above process
- GRCh38_decoy_ebv_phiX_alt_hla_chr.fa
- GRCh38_decoy_ebv_phiX_alt_hla_chr.fa.chrLenOnlyACGT_realChromosomes.tsv
- GRCh38_decoy_ebv_phiX_alt_hla_chr.fa.chrLength.tsv


#### dbSNP version 135

Downloaded from ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz

Post-processing for usage in ACEseq:
```
DBSNP_VERSION=135
zcat 00-All.vcf.gz |
    awk '/^#/{print} /VC=SNV/{ v=$8; sub(/.*dbSNPBuildID=/, "", v); sub(/;.*/, "", v); if (v~/^[0-9]+$/ && int(v)<='$DBSNP_VERSION') print }' |
    bgzip > 00-All.SNV.vcf.gz
tabix -p vcf 00-All.SNV.vcf.gz
```

#### Generating mappability track
The mappability file (GRCh38_Mappability_Align_100mer.bedGraph.gz) is created using the `create_mappability.sh` bash script.

The tools used have to be in the `tools` folder. The tools `gem-2-wig`, `gem-indexer`, `gem-mappability` are from the package *gem-tools* from the Vlaams Instituut voor Biotechnologie (VIB). 
Information about the tools can be found here: https://wiki.bits.vib.be/index.php/Create_a_mappability_track#Install_and_run_the_GEM_library_tools. The tools were downloaded from https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%202/. Corresponding paper should be this one: https://www.researchgate.net/publication/221776385_Fast_Computation_and_Applications_of_Genome_Mappability

The two tools `wigToBigWig` and `BigWigToBedGraph` are downloaded from http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/

Finally, `tabix` from htslib is used (see http://www.htslib.org/doc/tabix.html)

Run the script `sh create_mappability.sh`


#### Replication time
Replication time from individual cell lines from GRCh37 ENCODE data were lifted over to GRCh38, and averages were re-calculated.
The new R-object is uploaded to the `$repo_root/installation/GRCh38_related_files/time_mean_10KB.Rda`


#### Gaps and Centromers
- `gap.txt.gz` downloaded from `http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/gap.txt.gz`
- `centromeres.txt.gz` downloaded from `http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/centromeres.txt.gz`
- `centromeres_merged.txt.gz` created with the following command
``` 
zcat centromeres.txt.gz | sort -k 2 -V | awk 'BEGIN {printf "#bin\tchrom\tchromStart\tchromEnd\n"; chr=""} $2!=chr { if (end != ""){printf $1"\t" chr "\t" start "\t" end "\n"}; chr=$2; start=$3} {end=$4} END {printf $1"\t" chr "\t" start "\t" end "\n"}' | gzip > centromeres_merged.txt.gz
```
- `gap_with_centromeres.txt.gz` file created with the following command 
```
zcat centromeres_merged.txt.gz | tail -n +2 | awk ' BEGIN {OFS="\t"} {print $0, "1", "N", $4-$3, "centromere", "no"}' | gzip > gap_with_centromeres.txt.gz
```


#### GC content
The GC-content (`gc_content_hg38.txt`) is calculated directly from the reference genome with the script `calc_gc_content.py`.
```
python3 calc_gc_content -v -i ${reference_path}/GRCh38_decoy_ebv_phiX_alt_hla_chr.fa -o gc_content_hg38.txt
```
The -v flag increases vervosity. Note that you have to use python3!


#### Beagle reference files
The variants were downloaded for all the chromosomes mapped to hg38 reference genome
Info: https://www.internationalgenome.org/announcements/Variant-calls-from-1000-Genomes-Project-data-on-the-GRCh38-reference-assemlby/
FTP site: http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/

Added 'chr' prefix and converted the VCF files to BREF format using Beagle. Refer to the script `beagle_vcf_to_bref.sh`

This step will generate the following files,
- `ALL.chr${CHR_NAME}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.CHR.bref3`
- `ALL.chrX.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.CHR.bref3`


#### Beagle genetic map files
Downloaded from `http://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/plink.GRCh38.map.zip`

Add `chr` prefix

```
for chr in `seq 1 22` X ; do cat plink.chr${chr}.GRCh38.map | sed 's/^/chr/' > plink.chr${chr}.GRCh38.CHR.map; done
```


#### Local controls for no-control workflow (optional)
These are lift-over files from the hg19 workflow. New hg38 native files will be generated for next versions.


#### Exculsion list or blacklist files
These are lift-over files from the hg19 workflow. New hg38 native files will be generated for next versions.
`ACEseqWorkflow/resources/analysisTools/copyNumberEstimationWorkflow/artifact.homoDels.potentialArtifacts.hg38_liftover.txt`


#### Hg38 cytoband
Cytoband file was copied from ANNOVAR database files. Only the coordinates from Chr1-22, X and Y were kept.
```
cat ANNOVAR/annovar_April2018/humandb/hg38_cytoBand.txt | grep -v "_" | grep -v "^chrM" > hg38_cytoBand.txt
```