#!/bin/bash

. ./functions.sh

# https://stackoverflow.com/questions/41145041/list-files-modified-in-a-pull-request-within-travis
git remote set-branches --add origin "$TRAVIS_BRNACH"
git fetch
git diff origin/"$TRAVIS_BRANCH"

# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=AM HEAD..."$TRAVIS_BRANCH"


