/*
 * Copyright (c) 2017 The ACEseq workflow developers.
 *
 * Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).
 */

package de.dkfz.b080.co.files;

import de.dkfz.roddy.core.ExecutionContext;
import de.dkfz.roddy.knowledge.files.IndexedFileObjects;
import de.dkfz.roddy.knowledge.files.Tuple2;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by kleinhei on 6/16/14.
 */


public class PhaseGenotypeByChromosome extends IndexedFileObjects {

    private PhasedGenotypeFileGroupByChromosome phasedSnpFiles;

    private HaploblockFileGroupByChromosome haploblockFiles;

    public PhaseGenotypeByChromosome(IndexedFileObjects indexedFileObjects, ExecutionContext executionContext) {
        super(indexedFileObjects.getIndices(), indexedFileObjects.getIndexedFileObjects(), executionContext);
        Map<String, PhasedGenotypeFile> _phasedSnpFiles = new LinkedHashMap<>();
        Map<String, HaploblockGroupFile> _haploblockFiles = new LinkedHashMap<>();
        for (String chr : (List<String>) indices) {
            Tuple2<PhasedGenotypeFile, HaploblockGroupFile> tuple = (Tuple2<PhasedGenotypeFile, HaploblockGroupFile>) indexedFileObjects.getIndexedFileObjects().get(chr);
            _phasedSnpFiles.put(chr, tuple.value0);
            _haploblockFiles.put(chr, tuple.value1);
        }
        phasedSnpFiles = new PhasedGenotypeFileGroupByChromosome(_phasedSnpFiles);
        haploblockFiles = new HaploblockFileGroupByChromosome(_haploblockFiles);
    }

    public PhasedGenotypeFileGroupByChromosome getPhasedSnpFiles() {
        return phasedSnpFiles;
    }

    public HaploblockFileGroupByChromosome getHaploblockFiles() {
        return haploblockFiles;
    }

}

