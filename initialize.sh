#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

# Global configuration

# Error Handling
function on_error() { echo "error: [ ${BASH_SOURCE[1]} at line ${BASH_LINENO[0]} ]"; }
trap on_error ERR

# Alias Expansion
shopt -s expand_aliases
alias kwargs='(( $# )) && local'

# Kill Script Function
trap exit TERM
alias exit_script='kill -s TERM $$'

# Set Script Globals
_ROOT="$( cd "$(dirname "$0")" ; pwd -P )"
