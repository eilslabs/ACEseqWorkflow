/*
 * Copyright (c) 2017 The ACEseq workflow developers.
 *
 * Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).
 */

package de.dkfz.b080.co.aceseq;

/**
 * A static class for the storage of computational oncology based constants.
 */
@groovy.transform.CompileStatic
public final class ACEseqConstants {
    /**
     * Tool entries
     */
    public static final String TOOL_CNV_SNP_GENERATION = "cnvSnpGeneration";
    public static final String TOOL_CNV_SNP_GENERATION_WITHOUT_CONTROL = "cnvSnpGeneration_withoutControl";
    public static final String TOOL_REPLACE_BAD_CONTROL = "replaceBadControl";
    public static final String TOOL_MERGE_AND_FILTER_SNP_FILES = "mergeAndFilterSnpFiles";
    public static final String TOOL_MERGE_AND_FILTER_CNV_FILES = "mergeAndFilterCnvFiles";
    public static final String TOOL_MERGE_AND_FILTER_CNV_FILES_WITH_REPLACE_BAD_CONTROL = "mergeAndFilterCnvFiles_withReplaceBadControl";
    public static final String TOOL_ANNOTATE_COV_WIN = "annotateCnvFiles";
    public static final String TOOL_GET_GENOTYPES = "getGenotypes";
    public static final String TOOL_CREATE_UNPHASED_GENOTYPE = "createUnphasedGenotype";
    public static final String TOOL_PHASE_GENOTYPES = "phaseGenotypes";
    public static final String TOOL_PHASE_GENOTYPES_NOMPILEUP = "phaseGenotypes_noMpileup";
    public static final String TOOL_PHASE_GENOTYPEX = "phaseGenotypes_X";
    public static final String TOOL_PHASE_GENOTYPEX_NOMPILEUP = "phaseGenotypes_X_noMpileup";
    public static final String TOOL_ADD_HAPLOTYPES_TO_SNP_FILE = "addHaplotypesToSnpFile";
    public static final String TOOL_CREATE_CONTROL_BAF_PLOTS = "createControlBafPlots";
    public static final String TOOL_CORRECT_GC_BIAS = "correctGcBias";
    public static final String TOOL_GET_BREAKPOINTS = "getBreakpoints";
    public static final String TOOL_MERGE_BREAKPOINTS_AND_SV = "mergeBreakpointsAndSv";
    public static final String TOOL_MERGE_BREAKPOINTS_WITHOUT_SV = "mergeBreakpointsWithoutSv";
    public static final String TOOL_MERGE_BREAKPOINTS_AND_SV_CREST = "mergeBreakpointsAndSvCrest";
    public static final String TOOL_GET_SEGMENTS_AND_SNPS = "getSegmentsAndSnps";
    public static final String TOOL_MARK_HOMOZYGOUS_DELETIONS = "markHomozygousDeletions";
    public static final String TOOL_SEGMENTS_TO_SNP_DATA_HOMODEL = "segmentsToSnpDataHomodel";
    public static final String TOOL_CLUSTER_AND_PRUNE_SEGMENTS = "clusterAndPruneSegments";
    public static final String TOOL_SEGMENTS_TO_SNP_DATA_PRUNED = "segmentsToSnpDataPruned";
    public static final String TOOL_ESTIMATE_PEAKS_FOR_PURITY = "estimatePeaksForPurity";
    public static final String TOOL_ESTIMATE_PURITY_AND_PLOIDY = "estimatePurityAndPloidy";
    public static final String TOOL_GENERATE_RESULTS_AND_PLOTS = "generateResultsAndPlots";
//    public static final String TOOL_GENERATE_VCF_FROM_TAB = "generateVcfFromTab";
    public static final String TOOL_ESTIMATE_HRD_SCORE = "estimateHrdScore";

    public static final String PARM_CHR_INDEX = "PARM_CHR_INDEX";
    public static final String CHR_NAME = "CHR_NAME";
    public static final String CHR_NR = "CHR_NR";

    private ACEseqConstants() {
    }
}
