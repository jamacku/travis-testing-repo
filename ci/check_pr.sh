#!/bin/bash

. ./ci/functions.sh

tree .

# https://medium.com/@joey_9999/how-to-only-lint-files-a-git-pull-request-modifies-3f02254ec5e0
# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=b $(git merge-base HEAD $TRAVIS_BRANCH) > ../pr-changes.txt

echo "PR changes:"
cat ../pr-changes.txt

# Find modified shell scripts
readarray list_of_changes < ../pr-changes.txt
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  is_it_script "$file" && list_of_changed_scripts+=("$file")
done

echo "changed files: "
echo "${list_of_changed_scripts[@]}"

shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../pr-shellcheck.txt

cat ../pr-shellcheck.txt


git checkout master

shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../master-shellcheck.txt

cat ../master-shellcheck.txt


