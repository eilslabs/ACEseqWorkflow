== Description

Some description

== Run flags / switches

Switch                      Default Description
SV                          true    By default, the workflow will try to use an SV file for breakpoints
allowMissingSVFile          false   Allows the workflow to stop without an error, if the SV file does not exist
runWithCrest          		false   Run with crest output
runQualityCheckOnly      	false   Stop the workflow after the gc correction.
runMetaCNVGeneration        false   Run a meta step for the cnv generation. This submits a single,
									slightly optimized step instead of several (per chromosome) jobs.
isNoControlWorkflow	        false   Run analysis with matching control and estimate control genotypes based on tumor BAF

== Changelist

* Version update 6.0.0
- Changed the phasing routine. The program "impute2" was replaced by "Beagle". Files and tools were renamed accordingly.
- Generally renamed all tools and files from "imputeGenotype" to "phaseGenotype" (and so on) as the subroutine does not actually perform imputation but rather phasing.

* Version update to 5.0.1
- fixed density(NA) bug and index bug for frequencies (as.character) in clustering step

* Version update to 5.0.0
- introduced CNA.type 'AMP' (TCN>=2*ploidy + 1)
- do not use ChrX/Y for round/full ploidy determination
- fixed faulty assignment of 'neutral' to gonosomal segments in male samples
- fixed pruning bug (combineNeighbours, homozygousDel)
- force gender to be set in noControl cases
- enhanced cluster plots
- added CovBaf plots


* Version update to 4.0.3
- use fake controls from shared folder

* Version update to 4.0.2
- fixed several gap merging bugs (HRD score)

* Version update to 4.0.1
- smoothing: merge first segment after long gap

* Version update to 4.0.0
- fixed bug in HRD score determination (tcnStatePerChrom nrow vs length)
- write out file with segments contributing to HRD score
- introduced HRD score with gapped centromeres (numberHRDSmoothReduced)
- corrected LST and TAI calculation (changed centromere regions file)


* Version update to 3.0.0
- fixed 'artifact-1' artifact (allow for low purity solutions in this case)
- work with old (version < 2.x) ACEseq result files on rerun
- introduced ymaxcov_threshold for maximum TCN count represented in segment plots
- fixed bug in creation of json file (doubled first solution)
- fixed noControl filegroup bug
- fixed noControl control-bam file access issue
- run without SV in noControl cases
- use true|false for SV cvalue and not yes|no
- fixed bug contamination/sample swap detection (secondPeak index)


* Version update to 2.0.0
- add contours in 2D plots
- add 1.0 (instead of 0.00001) to lengths when getting log2 for weights to consider segments with length=1
- Add flags and checks for handling the sv file and remove null pointer exceptions
- fix bug in tcc ploidy estimation
- parametrized local minimum upper boundary (local_minium_upper_boundary_shift)

* Version update to 1.2.10
- add bioconda dependencies
- replace all occurences of qq.R and getopt2 by getopt
- replace all occurenced of name delly and crest, also in final output 
- change color for deletions(red ==>blue) and duplications (red ==> blue)
- enable modularization of workflow
- remove generateVCF job, add estiate HRD score
- remove dependency of haploblock files in cluster_and_prune_segments  
- add HRD score estimation, smooth segments and filter for blacklist segments
- add 0.00001 to lengths when getting log2 for weights to consider segments with length=1, which will be merged in a future release
- adjust colors for clustering so they are consistent across all three cluster plots

* Version update to 1.2.8-1
- remove vcf creation in final job (obsolete)

* Version update to 1.2.8
- comb_pro_extra and most_important_info contain X and Y
- removed GNL column
- new annotation of CNA.type (DEL/DUP/LOH/TCNNeutral/NA)
- new estimation of quality (length of subclonal over total mapped)

* Version update to 1.2.7-1/2
- removed dependencies on coConfigurations
- change of svOutputdirectory and set to default SOPHIA

* Version update to 1.2.7
- addition of tumorSample and controlSample variable as read out from bam file

* Version update to 1.2.6-*

- bugfix allowing coordinates for chrom2 in SV file to be smaller than chrom1 coordinates
- bugfix allowing chrom1 being decoy chromosome in case chrom2 is autosome|X|Y
- bugfix plots using print and ggplot2:ggsave to generate plots

* Version update to 1.2.6

- runparallel for impute moved from COWorkflows to ACEseqMethods.groovy
- sort most_important_info and comb_pro_extra file

* Version update to 1.2.1

- enable BAF plots as extra step, that is only run for paired workflow and only writes down checkpoint
- enable json with quality parameters for closest to diploid solution, should be read out by otp, file noted down in config.xml
- enable upgrade to R-3.3.1, R-2.15.0 is only working with exception (pscbs_all_R_2.15.R must be redefined as tool and path to pscbs lib should be given)
- better format of cnv_parameter files
- removed "set -x", pipefail etc.
- PSCBSgabs_delly.py
	- improved code
	- added selective column
- add noControl options
- cluster and prune take mean if two equally high peaks appear or for single peak remove bug
- add chromosome labels to general coverage plots
- remove chr prefixes throughout analysis
- make email option optional for gcCorrection
- be flexible on sv_type file, "id" column optional

* Version update to 1.0.189


pscbs_all.R: bugfix that screwed up chrlength

* Version update to 1.0.187


-stabilizing addition to pscbs_all.R

* Version update to 1.0.185

-bugfixes for pscbs_all.R

* Version update to 1.0.183






-pscbs_all.R and PSCBSall.sh:
	*scientific format of start and end here already, replace +Inf/-Inf with chromosome length/0
-adjustsAlleleFreqs and functions.R and purity_ploidy.R:
	*don't consider dbSNP position with 0 reads mapped in tumor
-manual_pruning.R
	*don't consider dbSNP position with 0 reads mapped in tumor and remove bug in case no main cluster is found


* Version update to 1.0.181


-convertTabTovcf.sh:
	*removed usage of id option (for pcawg output)
-convertToVcf.py:
	*libraries removed
	* default for id argument set (NA)
	*changed version number (for pcawg output)
	* added missing "\n" for header
	* added SAMPLE_ID line for header (pancan)
	*changed sample_$pid column name to TUMOR
-correctGCBias_functions.R:
	*corrected coordinates in coverage plots
-datatablePSCBSgaps.sh:
	*tabix for position not window (col5 instead of 1)
-haplotypes.sh:
	*tabix corrected (added -e)
-manual_pruning.R:
	*adjusted for no cluster within cluster limits
-merge_and_filter_cnv.py/merge_and_filter_snp.py:
	*removed coverage filter for tumor
-pscbs_all.R:
	*round coordinates with .5 (ceiling for start, floor for end)
-PSCBSgabs_plus_delly_points.py:
	*removed library
-pscbs_plots_functions.R:
	*fullPloidy calculation by largest fraction of genome instead of most segments in genome
	*annotation of LOH (cn,gain,loss) corrected
	*LOH definition adjusted instead of dhMean </> 0.8 using round(c1) and round(c2) (==0 for LOHs, != 0 for everything else)
-pscbs_plots.R:
	*added gc()
-purity_ploidy.R:
	*average coverage on autosomes instead of all chromosomes (better for males)
	*allow missing autosomes
-vcfAnno.sh:
	*rearranged order of script (first gender estimation)

-addition of fake control option:
	added scripts:
		*replaceControl.sh
		*replaceControlACEseq.R
 

* Version update to 1.0.158

extracted into single plugin

* Version update to 1.0.131

- plots					tab seperateed file with cnv parameters written
- correctGCBias:			extra file with qc parameters printed, conversion to json, parameter for scale adjustion added
- Change workflow class to override another execute method. This makes the workflow a bit cleaner.

* Version update to 1.0.114

-PSCBSgabs_plus_CRESTpoints.py :	add identifier column to sv_points file (used with DELLY calls)
-PSCBSgabs_plus_delly_points.py:	add identifier column to sv_points file, convert start coordinates to 1-based
-homozygous_deletion.pl:			added id column for sv file, adjust length calculation to inclusion of start AND End coordinate
-correctGCBias.R:					density estimation without restrictions for final corrected covRatio
-manual_pruning.R:					check for haploblock files to prevent script from failing after 2 hours due to missing files, plot Names with PID,
									new feature: merge clusters again after outlier removal and choose random cluster if 2 or more "mainClusters are found"
-purity_ploidy.R:					estimate and report average coverage, add minCoverage as optional parameter
-purity_ploidy_estimation_final.R:	bug fixes for balanced segments using wrong matrix,
									new feature: disallow copy number states of 0, don't punish balanced segments with copy number down to -0.3
-functions.R:						soft limits for control SNPs used for peak calling (coverage dependant), no limits for tumor SNPs, single threat for running
-purityPloidity_EstimateFinal.sh:	add PID as parameter
-analysisCopyNumberEstimation.xml:	adjust settings for peak calling to actually used resources
-pscbs_plots_functions.R:			convert 0.5 coordinates to integer values, don't allow scientific format for output files

* Version update to 1.0.109

* Version update to 1.0.105

* Version update to 1.0.104

-bug fix: read all lines of breakpoint.txt to avoid missing information on chr 1 
* Version update to 1.0.103
