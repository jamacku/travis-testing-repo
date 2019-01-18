#!/bin/bash

# Get number of newest and second newest revision
REV=($(git log --name-only --oneline --max-count=2 | awk '{ print $1 }' | awk '/[0-9a-f]{7}/ { print }'))

# Revisions are in this order [New, Old]
echo "Building from revisions:"
echo "${REV[@]}"

# Maybe better would be just take all rows instead of first one
FIL=($(git log --name-only --oneline --max-count=1 | awk '{ print $1 }' | awk '/[^'${REV[0]}']/ { print }'))

echo "${FIL[@]}"

# Check for shell script files

# get paths to changed shell files
# git log --name-only --oneline --max-count=2
# git log --name-only --oneline --max-count=2 | awk '/[0-9a-f]{7} / { print $1 }' 
# git log --name-only --oneline --max-count=2 | awk '/[0-9a-f]{7} / { print $1 } /sh/ { print $1 }'
# git log --name-only --oneline --max-count=2 | awk '{ print $1 }' | awk '/[0-9a-f]{7}/ { print } /sh/ { print }'

#------------#
# ShellCheck #        
#------------#

shellcheck "$PWD"/script.sh
NE="$?"

#if [ $? -eq 0 ]; then
#  echo "NEW BUILD is OK!"
#else
#  echo "NEW BUILD is WRONG!"
#fi

#Check for prev commit
git checkout ${REV[1]}
shellcheck "$PWD"/script.sh

exit $NE

#if [ $? -eq 0 ]; then
#  echo "OLD BUILD is OK!"
#else
#  echo "OLD BUILD is WRONG!"
#fi

#Pass final exit status for build
#exit 
