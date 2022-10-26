#!/bin/bash
function usage() {
  echo "Usage: freespace [-r] [-t num file1 [file2...]"
  echo "  -r      Recursive mode"
  echo "  -t num  Set cutoff time (default is 48)"
  exit $1
}

function rmIfOld() {
  local filePath=$1

  let msCutDate=$(date +%s) - $cutAgeSeconds
  fileModificationDateSeconds=$(date -r "${filePath}" +%s)
  if [ ${msCutDate} -gt ${fileModificationDateSeconds} ]
  then
    rm -f "${filePath}"
  fi
}

function freeFileSpace ( ) {
  local fpath=$1

  local fname=$(basename $fpath)
  local fileType=$(file $fname | cut -d : -f 2)
  local newPath=$(echo $fpath | sed -E "s/(.*)$fname/\1fc-$fname/")

  if [[ "$fileType" =~ $ZIPTYPES ]]
  then
    if [[ $fname =~ ^fc\- ]]
    then
      rmIfOld $fpath
    else
      mv $fpath $newPath && touch $newPath
    fi
  else
    zip -rm $newPath.zip $fpath
  fi
}

# main
ZIPTYPES="((zip)|(compress)|(archive))"
recurseLimit='-maxdepth 1'
let cutAgeSeconds=48*60*60

while getopts "rt:h" opt
do
  case $opt in
    r) recurseLimit="";; # unlimited
    t) cutAgeSeconds=$(( $OPTARG * 60 * 60 ));;
    h) usage 0;;
    \?) usage 1;;
  esac
done
shift $(( OPTIND - 1 ))

for opFile in "$@"
do
  find "$opFile" $recurseLimit -type f | while read f
    do
      freeFileSpace $f
    done
done
