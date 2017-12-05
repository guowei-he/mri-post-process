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

main() {
  # Check input
  if [[ "$#" -ne 1 ]]; then
    err "Usage: mri-post-process.sh dcm-folder"
  fi
  in="$1"
  base="$(basename ${in})"
  if [[ ! -d "${in}" ]]; then
    err "Error: Input ${in} does not exist."
  fi
  if [[ ! "${in}" = /* ]]; then
    err "Error: Input ${in} has to be absolute path."
  fi

  # Check global variables
  if [[ ! -f "${converter}" ]]; then
    err "Error: Converter ${converter} is not available."
  fi
  if [[ ! -d "${outbase}" ]]; then
    err "Error: Output base dir ${outbase} does not exist."
  fi
  out="${outbase}/${base}"
  if [[ -d "${out}" ]]; then
    err "Error: Output dir ${out} already exists! Make sure you are not overwriting. If sure, delete it and continue."
  else
    mkdir -p ${out}
  fi

  if [[ ! -d "${out}" ]]; then
    err "Error: Failed to create ${out}."
  fi

  # Convert the file
  cd ${in}
  find ./ -name "*.IMA" | xargs -I {} dirname {} | sort -u | xargs -I {}  mkdir -p ${out}/{}
  find ./ -name "*.IMA" | xargs -I {} dirname {} | sort -u | xargs -I {}  ${converter} -b y -z n -o ${out}/{} {}
}

main "$@"
