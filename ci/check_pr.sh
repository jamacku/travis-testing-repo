#!/bin/bash

. ./functions.sh

# https://stackoverflow.com/questions/41145041/list-files-modified-in-a-pull-request-within-travis
git remote set-branches --add origin "$TRAVIS_BRNACH"
git fetch
git diff origin/"$TRAVIS_BRANCH"

# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=AM HEAD..."$TRAVIS_BRANCH" pr-changes.txt

# Find modified shell scripts
readarray list_of_changes < pr-changes.txt
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  is_it_script "$file" && list_of_changed_scripts+=("$file")
done

echo "changed files: "
echo "${list_of_changed_scripts[@]}"
