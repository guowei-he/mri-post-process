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
  if [[ ! -d "${in}" ]]; then
    err "Error: Input ${in} does not exist."
  fi

  # Check global variables
  if [[ ! -f "${converter}" ]]; then
    err "Error: Converter ${converter} is not available."
  fi
  if [[ ! -d "${outbase}" ]]; then
    err "Error: Output base dir ${outbase} does not exist."
  fi
  out="${outbase}/$(basename ${in})"
  if [[ -d "${out}" ]]; then
    err "Error: Output dir ${out} already exists! Make sure you are not overwriting."
  else
    mkdir ${out}
  fi
  # Convert the file
  # Transfer the file
}

main "$@"