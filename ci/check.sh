#!/bin/bash

# Get number of newest and second newest revision
rlist=($(git log --name-only --oneline --max-count=2 | awk '{ print $1 }' | awk '/[0-9a-f]{7}/ { print }'))

# Revisions are in this order [New, Old]
echo "Building from revisions:"
echo "Old revision: ${rlist[1]}"
echo "New revision: ${rlist[0]}"
echo "------------"

# Maybe better would be just take all rows instead of first one
flist=($(git log --name-only --oneline --max-count=1 | awk '{ print $1 }' | awk '/[^'${rlist[0]}']/ { print }'))
echo "List of changed files since last revision: "
printf "%s\n" "${flist[@]}"
echo "------------"

#------------#
#    NEW     #
#------------#

printf "\n\n"
echo "---------------------"
echo "Checking NEW REVISION"
echo "---------------------"
printf "\n"

# Check for shell script files
echo "List of shell files based on .script-list.txt: "
cat "$PWD"/.script-list.txt
echo "------------"

shflist=()
for file in "${flist[@]}"; do
  grep -Fxq "$file" .script-list.txt && shflist+=("$file")
done

echo "List of shell files to check: "
printf '%s\n' "${shflist[@]}"
echo "------------"

#for file in "${shflist[@]}"; do
# https://github.com/kdudka/csmock/blob/master/scripts/run-shellcheck.sh#L10
# xargs -r shellcheck --format=gcc "${shflist[@]}"
shellcheck --format=gcc "${shflist[@]}" > "$PWD"/new.err
cat "$PWD"/new.err
#done

#if [ $? -eq 0 ]; then
#  echo "NEW BUILD is OK!"
#else
#  echo "NEW BUILD is WRONG!"
#fi

#------------#
#    OLD     #
#------------#

printf "\n\n"
echo "-----------------------"
echo "Checking OLDER REVISION"
echo "-----------------------"
printf "\n"

#Checkout second newest revision
git checkout ${rlist[1]}

# Check for shell script files
echo "List of shell files based on .script-list.txt: "
cat "$PWD"/.script-list.txt
echo "------------"

oldshflist=()
for file in "${shflist[@]}"; do
  grep -Fxq "$file" .script-list.txt && oldshflist+=("$file")
done

echo "List of shell files to check: "
printf '%s\n' "${oldshflist[@]}"
echo "------------"

#for file in "${shflist[@]}"; do
# https://github.com/kdudka/csmock/blob/master/scripts/run-shellcheck.sh#L10
# xargs -r shellcheck --format=gcc "${oldshflist[@]}"
shellcheck --format=gcc "${oldshflist[@]}" > "$PWD"/old.err
cat "$PWD"/old.err
#done

#if [ $? -eq 0 ]; then
#  echo "OLD BUILD is OK!"
#else
#  echo "OLD BUILD is WRONG!"
#fi

#------------#
#    OLD     #
#------------#

printf "\n\n"
echo "---------------------"
echo "Comparing ERROR FILES"
echo "---------------------"
printf "\n"

exitstatus=0

csdiff --fixed old.err new.err > "$PWD"/fixes.err
if wc -l < "$PWD"/fixes.diff -ne 0; then
  echo "Fixed bugs since last version:" 
  csgrep "$PWD"/fixes.diff
  echo "------------"
else
  echo "No Fixes since last version!"
  echo "------------"
fi

csdiff old.err new.err > "$PWD"/bugs.err
if wc -l < "$PWD"/bugs.diff -ne 0; then
  echo "Added bugs since last version:" 
  csgrep "$PWD"/bugs.diff
  echo "------------"
  $exitstatus=1
else
  echo "No changes since last version!" 
  echo "------------"
  $exitstatus=0
fi

#Pass final exit status for build
exit $exitstatus 
