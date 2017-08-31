
REFERENCE_GENOME=false
dbSNP_FILE=false
MAPPABILITY_FILE=false
CHROMOSOME_LENGTH_FILE=false
IMPUTE_FILES=false

mkdir 1KGRef
mkdir databases
mkdir stats
mkdir databases/ENCODE
mkdir -p databases/1000genomes/IMPUTE
mkdir databases/UCSC
mkdir -p databases/dbSNP/dbSNP_135

if [[ $REFERENCE_GENOME != "true" ]] 
then
        wget -P 1KGRef ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
fi

if [[  $dbSNP_FILE != "true" ]]
then
       installationpath=`pwd`
       cd databases/dbSNP/dbSNP_135
       bash prepare_dbSNPFile.sh
	cd $installationpath
fi

if [[  $MAPPABILITY_FILE != "true" ]]
then
       wget -P databases/UCSC  http://hgdownload.soe.ucsc.edu/goldenPath/hg18/encodeDCC/wgEncodeMapability/wgEncodeCrgMapabilityAlign100mer.bw.gz
fi

if [[  $CHROMOSOME_LENGTH_FILE != "true" ]] 
then
       wget -qO- http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/chromInfo.txt.gz  | zcat | grep -Pv "(_)|(chrM)" | sed -e '1i\#chrom\tsize\tfileName' >stats/chrlengths.txt
fi

if [[ $statFiles == "true" ]]
       wget -P stats https://github.com/eilslabs/ACEseqWorkflow/blob/github/installation/hg19_GRch37_100genomes_gc_content_10kb.txt
       wget -P ENCODE https://github.com/eilslabs/ACEseqWorkflow/blob/github/installation/ReplicationTime_10cellines_mean_10KB.Rda

if [[  $IMPUTE_FILES != "true" ]]
then
	wget -P databases/1000genomes/IMPUTE https://mathgen.stats.ox.ac.uk/impute/ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz
	tar -xzvf ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz -C 1000genomes/databases/IMPUTE
	wget -P databases/1000genomes/IMPUTE https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz
	tar -xzvf ALL_1000G_phase1integrated_v3_impute.tgz -C 1000genomes/databases/IMPUTE
fi
