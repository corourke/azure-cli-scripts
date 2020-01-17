#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

echo "Initializing..."

_GREY="\033[37m"
_GREEN="\033[32m"
_YELLOW="\033[33m"
_RED="\033[31m"
_NOCOLOR="\033[0m"

# Check for Azure CLI Installed
_=$(command -v az);
if [ "$?" != "0" ]; then
  printf -- "${_RED}ERROR: You don't seem to have the Azure CLI installed.\n";
  printf -- "See: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest  \033[0m\n";
  exit 1;
fi;

# Exit on error, Exit on unset variables
set -o errexit
set -o nounset

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

# Utility
Status () {
  printf -- "${_GREEN}${1}${_NOCOLOR}\n"
}

# This is a bit of trickery that presents each named variable for modification
Prompt () {
  printf -- "${_YELLOW}Please confirm:\n${_NOCOLOR}"
  for var in $*
  do
    old_val=${!var}
    read -p "$var [${old_val}]: " input
    printf -v "$var" '%s' ${input:-${old_val}}
  done
  printf -- "\n"
}
