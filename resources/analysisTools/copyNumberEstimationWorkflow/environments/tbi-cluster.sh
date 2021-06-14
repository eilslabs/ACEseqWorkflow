#!/usr/bin/env bash
# Copyright (c) 2017 The ACEseq workflow developers.
# Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).
# Load a Conda environment.

module load "htslib/$HTSLIB_VERSION"
module load "perl/$PERL_VERSION"
module load "python/$PYTHON_VERSION"
module load "R/$RSCRIPT_VERSION"
module load "bedtools/$BEDTOOLS_VERSION"
module load "samtools/$SAMTOOLS_VERSION"
module load "vcftools/$VCFTOOLS_VERSION"

source /dkfz/cluster/virtualenvs/warsow/python_2.7.9_SNVCalling_1.2.166-1/bin/activate

export BGZIP_BINARY=bgzip
export TABIX_BINARY=tabix

module load "perl/$PERL_VERSION"
export PERL_BINARY=perl

module load "python/$PYTHON_VERSION"
export PYTHON_BINARY=python

module load "R/$RSCRIPT_VERSION"
export RSCRIPT_BINARY=Rscript

module load "bedtools/$BEDTOOLS_VERSION"
export INTERSECTBED_BINARY=intersectBed

module load "vcftools/$VCFTOOLS_VERSION"
export VCFTOOLS_SORT_BINARY=vcf-sort

module load "samtools/$SAMTOOLS_VERSION"
export SAMTOOLS_BINARY=samtools

module load "bcftools/$BCFTOOLS_VERSION"
export BCFTOOLS_BINARY=bcftools

module load "java/$JAVA_VERSION"
export JAVA_BINARY=java
