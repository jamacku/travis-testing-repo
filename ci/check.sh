#!/bin/bash

# Get number of newest and second newest revision
rlist=($(git log --name-only --oneline --max-count=2 | awk '{ print $1 }' | awk '/[0-9a-f]{7}/ { print }'))

# Revisions are in this order [New, Old]
echo "Building from revisions:"
echo "Old revision: ${rlist[1]}"
echo "New revision: ${rlist[0]}"

# Maybe better would be just take all rows instead of first one
flist=($(git log --name-only --oneline --max-count=1 | awk '{ print $1 }' | awk '/[^'${rlist[0]}']/ { print }'))
echo "List of changed files since last revision: "
printf '%s\n' "${flist[@]}"

# Check for shell script files
cat "$PWD"/.script-list.txt

shflist=()
for file in "${flist[@]}"
do
  grep -Fxq "$file" .script-list.txt && shflist+=("$file")
done

echo "List of shell files: "
printf '%s\n' "${shflist[@]}"

#------------#
# ShellCheck #        
#------------#

shellcheck "$PWD"/script.sh
nexit="$?"

#if [ $? -eq 0 ]; then
#  echo "NEW BUILD is OK!"
#else
#  echo "NEW BUILD is WRONG!"
#fi

#Check for prev commit
git checkout ${rlist[1]}
shellcheck "$PWD"/script.sh

exit $nexit

#if [ $? -eq 0 ]; then
#  echo "OLD BUILD is OK!"
#else
#  echo "OLD BUILD is WRONG!"
#fi

#Pass final exit status for build
#exit 
