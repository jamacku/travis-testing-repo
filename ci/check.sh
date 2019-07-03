#!/bin/bash

#------------#
#    NEW     #
#------------#

curl --silent https://patch-diff.githubusercontent.com/raw/jamacku/travis-testing-repo/pull/$TRAVIS_PULL_REQUEST.diff > diffile 
readarray flist < "$PWD"/.script-list.txt
shflist=()
for file in "${flist[@]}"; do
  cat "$PWD"/diffile | grep --silent file && shflist+=("$file")
done

shellcheck --format=gcc "${shflist[@]}" > "$PWD"/../new.err
cat "$PWD"/../new.err
#done

#------------#
#    OLD     #
#------------#

git checkout "$TRAVIS_BRANCH"

shellcheck --format=gcc "${shflist[@]}" > "$PWD"/../old.err
cat "$PWD"/../old.err
#done

#------------#
# VALIDATION #
#------------#

printf "\n\n"
echo "---------------------"
echo "Comparing ERROR FILES"
echo "---------------------"
printf "\n"

exitstatus=0

csdiff --fixed "$PWD"/../old.err "$PWD"/../new.err > "$PWD"/../fixes.err
if [ "$(cat "$PWD"/../fixes.err | wc -l)" -ne 0 ]; then
  echo "Fixed bugs since last version:" 
  csgrep "$PWD"/../fixes.err
  echo "------------"
else
  echo "No Fixes since last version!"
  echo "------------"
fi

csdiff "$PWD"/../old.err "$PWD"/../new.err > "$PWD"/../bugs.err
if [ "$(cat "$PWD"/../bugs.err | wc -l)" -ne 0 ]; then
  echo "Added bugs since last version:" 
  csgrep "$PWD"/../bugs.err
  echo "------------"
  exitstatus=1
else
  echo "No changes since last version!" 
  echo "------------"
  exitstatus=0
fi

#Pass final exit status for build
exit $exitstatus 
