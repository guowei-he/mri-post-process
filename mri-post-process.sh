#!/bin/bash
#
# This script converts the dcm file to nii format. Then upload the nii file to remote server.
#
# Usage:
#   mri-post-process.sh dcm-folder
#
# Notice:
#   This script is expected to be called by automator, and to 'batch'
#   The log, by default in 'batch', will be sent as mails to the user.
#
# Prerequisite:
#   1. dcm2niix converter
#
# Author:
#   Guowei He <gh50@nyu.edu>
#

err() { echo "$@" 1>&2; exit 1; }

# Global variables
outbase="/Users/user/Desktop/output"
converter="/Users/user/Desktop/dcm2niix"

check_input_size() {
  local indir ntries seconds_between_tries previous_size current_size is_timeout
  indir="$1"
  ntries=20
  seconds_between_tries=60
  previous_size="-1"
  is_timeout="true"
  for i in $(seq 1 ${ntries}); do
    sleep ${seconds_between_tries}
    current_size=$(du -d 0 "${indir}" | awk '{print $1}')
    if [[ "${current_size}" == "${previous_size}" ]]; then
      is_timeout="false"
      echo "Input is complete at trail ${i}. Input size: ${current_size}. $(date)"
      break
    fi
    echo "Trail $i, input still not complete. ${current_size} vs ${previous_size}. $(date)"
    previous_size="${current_size}"
  done
  if [[ "${is_timeout}" == "true" ]]; then
    err "Input is not complete. Waited until $(date)."
  fi
}

main() {
  # Check input
  if [[ "$#" -ne 1 ]]; then
    err "Usage: mri-post-process.sh dcm-folder"
  fi
  indir="$1"
  base="$(basename ${indir})"
  if [[ ! -d "${indir}" ]]; then
    err "Error: Input ${indir} does not exist."
  fi
  if [[ ! "${indir}" = /* ]]; then
    err "Error: Input ${indir} has to be absolute path."
  fi
  # wait until the input folder is complete / size not changing
  check_input_size "${indir}"

  # Check global variables
  if [[ ! -f "${converter}" ]]; then
    err "Error: Converter ${converter} is not available."
  fi
  if [[ ! -d "${outbase}" ]]; then
    err "Error: Output base dir ${outbase} does not exist."
  fi
  outdir="${outbase}/${base}"
  if [[ -d "${outdir}" ]]; then
    err "Error: Output dir ${outdir} already exists! Make sure you are not overwriting. If sure, delete it and continue."
  else
    mkdir -p ${outdir}
  fi

  if [[ ! -d "${outdir}" ]]; then
    err "Error: Failed to create ${outdir}."
  fi

  # Convert the file
  cd ${indir}
  find ./ -name "*.IMA" | xargs -I {} dirname {} | sort -u | xargs -I {}  mkdir -p ${outdir}/{}
  find ./ -name "*.IMA" | xargs -I {} dirname {} | sort -u | xargs -I {}  ${converter} -b y -z i -o ${outdir}/{} {}
}

main "$@"
