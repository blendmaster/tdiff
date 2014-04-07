#!/usr/bin/env bash

LOCAL=$1
REMOTE=$2

TEMP_LOCAL=$(mktemp /tmp/tdiff.XXX)
cp $LOCAL $TEMP_LOCAL
TEMP_REMOTE=$(mktemp /tmp/tdiff.XXX)
cp $REMOTE $TEMP_REMOTE

# http://stackoverflow.com/a/10660730/811153
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

firefox "http://localhost:7416/tdiff/?left=$(rawurlencode "$TEMP_LOCAL")&right=$(rawurlencode "$TEMP_REMOTE")&pwd=$(rawurlencode "$PWD")"
