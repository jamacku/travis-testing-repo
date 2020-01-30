#!/bin/bash

# Function to check whether input param is on list of shell scripts
# $1 - <string> relative path to file
is_it_script () {
  [ $# -eq 0 ] && return 1
  # test
  return 0
}

