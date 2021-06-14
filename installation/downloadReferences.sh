#!/bin/bash

# tell bash to abort on error
set -o pipefail
set -u
set -eE
trap 'echo "Download incomplete. Please restart script."' ERR

# convenience function to create a directory and change into it
mkdir_cd() {
    mkdir -p "$1"
    cd "$1"
}

# compute an MD5 sum over all files found recursively in the current directory
# and check it against the MD5 sum given in the variable EXPECTED_MD5SUM
check_md5sum() {
    local FILES=$(find -type f | sort)
    local MD5SUM=$([ -n "$FILES" ] && cat $FILES | md5sum | cut -f1 -d' ')
    [ "$EXPECTED_MD5SUM" = "$MD5SUM" ]
}


###############################################################################
# create download directory
###############################################################################

mkdir_cd hg19_GRCh37_1000genomes

###############################################################################
# download reference genome
###############################################################################
(
    mkdir_cd sequence/1KGRef

    EXPECTED_MD5SUM=12a0bed94078e2d9e8c00da793bbc84e
    check_md5sum && exit 0 || echo downloading reference genome....

    wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
    gunzip hs37d5.fa.gz

    check_md5sum
)

###############################################################################
# download dbSNP database
###############################################################################
(
    DBSNP_VERSION=135
    mkdir_cd databases/dbSNP/dbSNP_$DBSNP_VERSION

    EXPECTED_MD5SUM=fed2a31b5a5d8fe12e072576c0c17199
    check_md5sum && exit 0 || echo downloading dbSNP file....

    # CITATION
    # As a NCBI Resource: "Sherry ST, Ward MH, Kholodov M, Baker J, Phan L, Smigielski EM, Sirotkin K. dbSNP: the NCBI database of genetic variation. Nucleic Acids Res. 2001 Jan 1;29(1):308-11."
    # As a whole for a specific build (use this!) : "Database of Single Nucleotide Polymorphisms (dbSNP). Bethesda (MD): National Center for Biotechnology Information, National Library of Medicine. (dbSNP Build ID: 141 ). Available from: http://www.ncbi.nlm.nih.gov/SNP/"
    # A single or a range of Submitted SNP (ss) or Reference SNP (rs) entries: "Database of Single Nucleotide Polymorphisms (dbSNP). Bethesda (MD): National Center for Biotechnology Information, National Library of Medicine. dbSNP accession:{ss1 or ss1 – ss100}, (dbSNP Build ID: 141). Available from: http://www.ncbi.nlm.nih.gov/SNP/"

    # DOWNLOAD
    DBSNP_BASE_URL="ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh37p13/VCF"
    wget -c "$DBSNP_BASE_URL/README.txt"
    wget -c "$DBSNP_BASE_URL/00-All.vcf.gz"

    # POST PROCESSING
    # extract SNPs from dbSNP version 135 and older
    zcat 00-All.vcf.gz |
    awk '/^#/{print} /VC=SNV/{ v=$8; sub(/.*dbSNPBuildID=/, "", v); sub(/;.*/, "", v); if (v~/^[0-9]+$/ && int(v)<='$DBSNP_VERSION') print }' |
    bgzip > 00-All.SNV.vcf.gz
    tabix -p vcf 00-All.SNV.vcf.gz

    # CLEANUP
    rm -f 00-All.vcf.gz

    check_md5sum
)

###############################################################################
# download mappability file
###############################################################################
(
    mkdir_cd databases/UCSC

    EXPECTED_MD5SUM=3d12d0a4d7afdb52cfd10f886d48b5f0
    check_md5sum && exit 0 || echo downloading mappability file....

    wget -c http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeMapability/wgEncodeCrgMapabilityAlign100mer.bigWig
    bigWigToBedGraph wgEncodeCrgMapabilityAlign100mer.bigWig /dev/stdout | bgzip > wgEncodeCrgMapabilityAlign100mer_chr.bedGraph.gz
    tabix -p bed wgEncodeCrgMapabilityAlign100mer_chr.bedGraph.gz
    rm -f wgEncodeCrgMapabilityAlign100mer.bigWig

    check_md5sum
)

###############################################################################
# download replication timings
###############################################################################
(
    mkdir_cd databases/ENCODE

    EXPECTED_MD5SUM=2a63b34a737383af2a3f7eb32801a5fa
    check_md5sum && exit 0 || echo downloading replication timing file....

    wget -c https://raw.githubusercontent.com/eilslabs/ACEseqWorkflow/github/installation/ReplicationTime_10cellines_mean_10KB.Rda

    check_md5sum
)

###############################################################################
# download chromosome statistics
###############################################################################
(
    mkdir_cd stats

    EXPECTED_MD5SUM=801bdaa8c3b0d5c18a0637b0b29fd337
    check_md5sum && exit 0 || echo downloading stats files....

    wget -c http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/chromInfo.txt.gz
    zcat chromInfo.txt.gz | grep -Pv "(_)|(chrM)" | sed -e '1i\#chrom\tsize\tfileName' > chrlengths.txt
    rm -f chromInfo.txt.gz

    wget -c https://raw.githubusercontent.com/eilslabs/ACEseqWorkflow/github/installation/hg19_GRch37_100genomes_gc_content_10kb.txt

    check_md5sum
)

###############################################################################
# download Beagle database
###############################################################################
(
    mkdir_cd databases/Beagle_references

    EXPECTED_MD5SUM=529947b78dbedfb7a947b530da510887
    check_md5sum && exit 0 || echo downloading Beagle reference files....

    for chr in {1..22}; do wget -c "http://bochet.gcc.biostat.washington.edu/beagle/1000_Genomes_phase3_v5a/b37.bref3/chr${chr}.1kg.phase3.v5a.b37.bref3"; done
    wget -c "http://bochet.gcc.biostat.washington.edu/beagle/1000_Genomes_phase3_v5a/b37.bref3/chrX.1kg.phase3.v5a.b37.bref3"

    check_md5sum
)

###############################################################################
# download genetic maps
###############################################################################
(
    mkdir_cd databases/genetic_maps

    EXPECTED_MD5SUM=37a6b0f29695cd87a3249065a1eae420
    check_md5sum && exit 0 || echo downloading genetic maps....

    wget -c "http://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/plink.GRCh37.map.zip"
    unzip plink.GRCh37.map.zip
    rm plink.GRCh37.map.zip

    check_md5sum
)

echo "All files downloaded successfully"