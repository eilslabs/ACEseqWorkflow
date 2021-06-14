#!/bin/bash

# Copyright (c) 2017 The ACEseq workflow developers.
# Distributed under the MIT License (license terms are at https://www.github.com/eilslabs/ACEseqWorkflow/LICENSE.txt).

dieWith() {
  local msg="${1:?No error message}"
  local ec="${2:-$?}"
  echo "$msg: exit code $ec" >> /dev/stderr
  exit "$ec"
}
