#!/bin/bash

## \file
## \TODO This file implements a very trivial feature extraction; use it as a template for other front ends.
## 
## Please, read SPTK documentation and some papers in order to implement more advanced front ends.

# Base name for temporary files
base=/tmp/$(basename $0).$$ 

# Ensure cleanup of temporary files on exit
trap cleanup EXIT
cleanup() {
   \rm -f $base.*
}

if [[ $# != 3 ]]; then
   echo "$0 fm mfcc_order melbank_order input.wav output.mfcc"
   exit 1
fi

fm=$1
mfcc_order=$2
melbank_order=$3
inputfile=$4
outputfile=$5

UBUNTU_SPTK=0
if [[ $UBUNTU_SPTK == 1 ]]; then
   # In case you install SPTK using debian package (apt-get)
   X2X="sptk x2x"
   FRAME="sptk frame"
   WINDOW="sptk window"
   MFCC="sptk mfcc"
else
   # or install SPTK building it from its source, para usuarios de mac
   X2X="x2x"
   FRAME="frame"
   WINDOW="window"
   MFCC="mfcc"
fi

# Main command for feature extration
sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$MFCC -l 240 -m $mfcc_order> $base.mfcc || exit 1

# Our array files need a header with the number of cols and rows:
ncol=$((mfcc_order)) # mfcc p =>  (c0 c1 c2 ... c(p-1)) 
# nrow=`$X2X +fa < $base.lp | wc -l | perl -ne 'print $_/'$ncol', "\n";'`
nrow=$($X2X +fa < $base.mfcc | wc -l | perl -ne 'print $_/'$ncol', "\n";')

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.mfcc >> $outputfile

exit