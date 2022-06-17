#!/bin/sh
#
# Given a patch to extract from a patch set, compare just what the 'original' file should be (e.g. exclude lines starting with +)
#   <relative-file-name>:<line-number>, e.g.
#   crypto/ppccap.c:209
#
set +x
origfileinfo="$1"
patchset="$2"

if [ $# -ne 2 ]; then
  echo "Syntax: $0 <patch> <patch-set>"
  exit 4
fi
if ! patchtext=`extractpatch.sh $*`; then
	exit 4
fi
 
origfile=${origfileinfo%%:*}
origline=${origfileinfo##*:}

patchorigtext=`printf "%s" "${patchtext}" | grep -v '^+' | awk '{ print substr($0,2); }'`
patchsize=`printf "%s" "${patchorigtext}" | wc -l | awk ' { print $1 }'`
lines=$((patchsize+1))
fileorigtext=`tail +${origline} ${origfile} | head -${lines}`

printf "%s" "${patchorigtext}" >/tmp/orig.patch
printf "%s" "${fileorigtext}" >/tmp/orig.file
diff /tmp/orig.patch /tmp/orig.file
