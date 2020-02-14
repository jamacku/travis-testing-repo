#!/bin/bash

. ./ci/functions.sh

# ------------ #
#  FILE PATHS  #
# ------------ #

git status
git remote show origin

# https://medium.com/@joey_9999/how-to-only-lint-files-a-git-pull-request-modifies-3f02254ec5e0
# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=db "$(git merge-base HEAD "$TRAVIS_BRANCH")" > ../pr-changes.txt

# Find modified shell scripts
readarray list_of_changes < ../pr-changes.txt
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  # https://stackoverflow.com/questions/19345872/how-to-remove-a-newline-from-a-string-in-bash
  is_it_script "$file" && list_of_changed_scripts+=("./${file//[$'\t\r\n ']}")
done

# ------------ #
#  SHELLCHECK  #
# ------------ #

shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../pr-br-shellcheck.err
git checkout "$TRAVIS_BRANCH"
shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../dest-br-shellcheck.err

set -x

# ------------ #
#  VALIDATION  #
# ------------ #

exitstatus=0

csdiff --fixed "../dest-br-shellcheck.err" "../pr-br-shellcheck.err" > ../fixes.log
if [ "$(cat ../fixes.log | wc -l)" -ne 0 ]; then
  echo "Fixed bugs:" 
  csgrep ../fixes.log
  echo "------------"
else
  echo "No Fixes!"
  echo "------------"
fi

csdiff --fixed "../pr-br-shellcheck.err" "../dest-br-shellcheck.err" > ../bugs.log
if [ "$(cat ../bugs.log | wc -l)" -ne 0 ]; then
  echo "Added bugs, NEED INSPECTION:" 
  csgrep ../bugs.log
  echo "------------"
  exitstatus=1
else
  echo "No bugs added Yay!" 
  echo "------------"
  exitstatus=0
fi

exit $exitstatus
