Input Parameters
==========================

Multiple parameters can be set with ACEseq though not all are necessary to change. This table gives and overview and description for all available parameters

.. csv-table:: "ACEseq parameters"
 :header: "name", "value", "type", "description"
 :widths: 8, 10, 10, 80

 aceseqOutputDirectory,${outputAnalysisBaseDirectory}/ACEseq_${tumorSample},path,
 svOutputDirectory,${outputAnalysisBaseDirectory}/SV_calls,path,
 crestOutputDirectory,${outputAnalysisBaseDirectory}/crest,path,
 cnvSnpOutputDirectory,${aceseqOutputDirectory}/cnv_snp,path,
 phasingOutputDirectory,${aceseqOutputDirectory}/phasing,path,
 plotOutputDirectory,${aceseqOutputDirectory}/plots,path,
 runWithoutControl,false,boolean,use control for analysis (false|true)
 minHT,5,integer,minimum number of consecutive SNPs to be considered for haploblocks
 snp_min_coverage,5,integer,"minimum coverage in control for SNP"
 cnv_min_coverage,5000,integer,"minimum coverage for 1kb windows to be considered for merging in 10kb windows"
 mapping_quality,1000,integer,"minimum mapping quality for 1kb windows to be considered for merging in 10kb windows (maximum mappability)"
 min_windows,5,integer,minimum number of 1kb windows fullfilling cnv_min_coverage and mapping_quality to obtain merged 10kb windows
 min_X_ratio,0.8,float,minimum ratio for number of reads on chrY per base over number of reads per base over whole genome to be considered as female
 min_Y_ratio,0.12,float,minimum ratio for number of reads on chrY per base over number of reads per base over whole genome to be considered as male
 LOWESS_F,0.1,float,f parameter for R lowess function
 SCALE_FACTOR,0.9,float,scale_factor for R lowess function
 COVERAGEPLOT_YLIMS,4,float,ylims for Rplots in GC-bias plots
 FILENAME_GC_CORRECT_PLOT,${plotOutputDirectory}/${pid}_gc_corrected.png,path,"gc-bias plot, before/during/after correction"
 GC_bias_json_key,gc-bias,string,key in GC-bias json
 FILE_DENSITYBETA,${aceseqOutputDirectory}/densityBeta.pdf,path,
 min_DDI_length,1000,integer,minimum length for DEL/DUP/INV to be considered for breakpoint integration
 selSVColumn,eventScore,string,column from bedpe file to be recored in ${pid}_sv_points.txt file
 min_seg_width,2000,integer,segmentByPairedPSCBS() minwidth parameter in PSCBS R package
 undo_SD,24,integer,segmentByPairedPSCBS() undo.SD parameter in PSCBS R package
 pscbs_prune_height,0,integer,pruneByHClust() parameter h in PSCBS R package
 min_segment_map,0.6,float,minimum average mappability over segment to be kept after segmentation
 min_seg_length_prune,9000,integer,maximum of segment to be considered for merging to neighbouring segment prior to clustering
 min_num_SNPs,15,integer,maximum number of SNPs in segment to be considered for merging to neighbouring segment prior to clustering
 clustering,yes,string,"should segments be clustered (yes|no), coerage and BAF will be estimated and assigned clusterwide"
 min_cluster_number,1,integer,minimum number of clusters to be tried with BIC
 min_membership,0.8,float,obsolete
 min_distance,0.05,float,min_distance
 haplogroupFilePrefix,haploblocks_chr,string,prefix for file with haplogroups per chromosome
 haplogroupFileSuffix,txt,string,suffix for file with haplogroups per chromosome
 haplogroupFilePath,${phasingOutputDirectory}/${haplogroupFilePrefix},path,
 min_length_purity,1000000,integer,minimum length of segments to be considered for tumor cell content and ploidy estimation
 min_hetSNPs_purity,500,integer,minimum number of control heterozygous SNPs in segments to be considered for tumor cell content and ploidy estimation
 dh_stop,max,string,
 min_length_dh_stop,1000000,integer,
 dh_zero,no,string,
 purity_min,0.3,float,minimum tumor cell content allowed
 purity_max,1.0,float,i
 ploidy_min,1.0,float,
 ploidy_max,6.5,float,
 SNP_VCF_CNV_PATH,${cnvSnpOutputDirectory}/${pid}.chr,path,If the value is changed the value for the filename pattern MUST also be changed.
 SNP_VCF_CNV_PATH_STR,${SNP_VCF_CNV_PATH},string,This value must be converted to a string because of a bug.
 SNP_SUFFIX,snp.tab.gz,string,

 CHR_NR,${CHR_PREFIX}${PARM_CHR_INDEX}${CHR_SUFFIX},string,
 CHR_NAME,${PARM_CHR_INDEX},string,
 AUTOSOME_INDICES,( {1..22} ),bashArray,
 CREST,yes,string,include SV breakpoints in analysis (yes|no)
 mpileup_qual,0,integer,quality used for parameter 'Q' in samtools mpileup
 CNV_MPILEUP_OPTS,"""-A -R -B -Q ${mpileup_qual} -q 1 -I """,string,options for mpileup to determine which bases/reads to use
 FILE_VCF_SUF,vcf,string,suffix for vcf files
 FILE_TXT_SUF,txt,string,suffix for txt files
 phasedGenotypesFilePrefix,phased_chr,string,prefix for phased genotypes file
 unphasedGenotypesFilePrefix,unphased_chr,string,prefix for unphased genotypes file
 phasedGenotypesFileSuffix,${FILE_VCF_SUF},string,suffix for phased genotypes file
 unphasedGenotypesFileSuffix,${FILE_VCF_SUF},string,suffix for unphased genotypes file
 BCFTOOLS_OPTS,"""-vgN """,string,bcftools options for imputation
 FAKE_CONTROL_POST,.cnv.anno.tab.gz,string,suffix for chromosome wise 1kb coverage files used for fake control workflow
 PATIENTSEX,male,string,patient sex used in case of no control workflow (male|female|klinefelter)
 CNV_ANNO_SUFFIX,cnv.anno.tab.gz,string,suffix for mappability annotated chromosome-wise 1kb coverage files
 CNV_SUFFIX,cnv.tab.gz,string,suffix chromosome-wise 1kb coverage files
 FILE_UNPHASED_PRE,${phasingOutputDirectory}/${unphasedGenotypesFilePrefix},path,
 FILE_PHASED_GENOTYPE,${phasingOutputDirectory}/phased_genotype_chr,path,
 FILE_SAMPLE_G,${phasingOutputDirectory}/sample_g.txt,path,sample_g file used by imputation on X chromosome for females
 MALE_FAKE_CONTROL_PRE,${pathToACEseqResults}/cnv_snp/${pid}.chr,path,path and prefix to chromosome-wise 1kb coverage file used for fake control workflow for male patients
 FEMALE_FAKE_CONTROL_PRE,${pathToACEseqResults}/cnv_snp/${pid}.chr,path,path and prefix to chromosome-wise 1kb coverage file used for fake control workflow for female patients
 PLOT_PRE,${aceseqOutputDirectory}/${pid}_plot,path,
 FILE_MOST_IMPORTANT_INFO_SEG_PRE,${pid}_most_important_info,string,
 FILE_MOST_IMPORTANT_INFO_SEG_POST,.txt,string,
 FILE_SEGMENT_VCF_PRE,${aceseqOutputDirectory}/${pid},path,
 FILE_SEGMENT_VCF_POST,.cnv.vcf,string,
 outputUMask,007,string,
 outputFileGroup,$accessGroup,,"group for output files and directories"
 outputAccessRights,"u+rw,g+rw,o-rwx",,"access rights for written files"
 outputAccessRightsForDirectories,"u+rwx,g+rwx,o-rwx",,"access rights for written directories"
 possibleControlSampleNamePrefixes,( blood),bashArray,"possible prefix of control bam if named ${prefix}_${pid}_$mergedBamSuffix"
 possibleTumorSampleNamePrefixes,( tumor ),bashArray,"same as possibleControlSampleNamePrefixes"
 referenceGenome_1KGRef,${path}/hs37d5.fa,path,"reference genome file"
 REFERENCE_GENOME,${referenceGenome_1KGRef},string,
 dbSNP_FILE,${path}/00-All.SNV.vcf.gz,path,
 MAPPABILITY_FILE,${path}/wgEncodeCrgMapabilityAlign100mer_chr.bedGraph.gz,path,"mappability file"
 CHROMOSOME_LENGTH_FILE,${path}/chrlengths.txt,path,
 REPLICATION_TIME_FILE,${path}/ReplicationTime_10cellines_mean_10KB.Rda,path,"replication timing file"
 GC_CONTENT_FILE,${path}/hg19_GRch37_100genomes_gc_content_10kb.txt,path,
 outputExecutionDirectory,${path}/exec_${executionTimeString},,"path to log files"
 mergedBamSuffix,merged.mdup.bam,string,"A list of all known suffixes for merged bam files. I.e. merged.dupmark.bam, merged.mdup.bam..." 
 mergedBamSuffixList,${mergedBamSuffix},string,"A list of all known suffixes for merged bam files. I.e. merged.dupmark.bam, merged.mdup.bam..."
 defaultMergedBamSuffix,${mergedBamSuffix},string,The default suffix for merged bam files when they are created by Roddy.
 libloc_PSCBS,,string,path to PSCBS library in R
 libloc_flexclust,,string,path to felxclust library in R
 BEAGLE_REFERENCE_FILE,${baseDirectoryReference}/tools_data/Beagle/chr${CHR_NAME}.1kg.phase3.v5a.b37.bref3,path
 BEAGLE_REFERENCE_FILE_X,${baseDirectoryReference}/tools_data/Beagle/chrX.1kg.phase3.v5a.b37.bref3,path
 BEAGLE_GENETIC_MAP,${baseDirectoryReference}/tools_data/genetic_maps/plink.chr${CHR_NAME}.GRCh37.map,path
 BEAGLE_GENETIC_MAP_X,${baseDirectoryReference}/tools_data/genetic_maps/plink.chrX.GRCh37.map,path
