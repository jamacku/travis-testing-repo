#!/bin/bash

. ./ci/functions.sh

# https://medium.com/@joey_9999/how-to-only-lint-files-a-git-pull-request-modifies-3f02254ec5e0
# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=db "$(git merge-base HEAD "$TRAVIS_BRANCH")" > ../pr-changes.txt

echo "PR changes:"
cat ../pr-changes.txt

# Find modified shell scripts
readarray list_of_changes < ../pr-changes.txt
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  # https://stackoverflow.com/questions/19345872/how-to-remove-a-newline-from-a-string-in-bash
  is_it_script "$file" && list_of_changed_scripts+=("./${file//[$'\t\r\n ']}")
done

echo "changed files: "
echo "${list_of_changed_scripts[@]}"

shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../pr-shellcheck.txt

echo "test:"
ls
cat "${list_of_changed_scripts[@]}"
cat ./script.sh

cat ../pr-shellcheck.txt

git checkout "$TRAVIS_BRANCH"

shellcheck --format=gcc "${list_of_changed_scripts[@]}" > ../merbr-shellcheck.txt

cat ../merbr-shellcheck.txt

