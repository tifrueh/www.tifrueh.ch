#!/bin/zsh

# === EXTERNAL VARIABLES =======================================================
#
# WWW_TIFRUEH_USER      Remote user to use.
# WWW_TIFRUEH_HOST      Remote host to use.
# WWW_TIFRUEH_PATH      Remote path to use.
# WWW_TIFRUEH_PATH_DFT  Remote path to use for drafts.

# Run in script directory.
cd "${0:A:h}"

# === HELPER VARIABLES =========================================================

ruser="${WWW_TIFRUEH_USER:-user}"
rhost="${WWW_TIFRUEH_HOST:-host}"
rpath="${WWW_TIFRUEH_PATH:-path}"
rpath_dft="${WWW_TIFRUEH_PATH_DFT:-path_dft}"
hugo_static="./static/"
hugo_public="./public/"
hugo_public_dft="./public-dft/"
hugo_content="./content/"
hugo_info_txt="${hugo_static}/info.txt"
info_template="info.txt
========

Hugo Information
----------------
Hugo version: %s
Build started at: %s

Version Information
-------------------
"

# === HELPER FUNCTIONS =========================================================

# Print a title.
#
# Synopsis:
#   printt TITLE
#
# Description:
#   TITLE       The title to print.
printt () {
    title="= ${1} "
    echo "${(r:80::=:)title}"
}

# Evaluate a command, but check with use first if WWW_TIFRUEH_HEADLESS is not
# set.
#
# Synopsis:
#   confirm_eval CMD
#
# Description:
#   CMD         The command to evaluate if the user confirms it.
confirm_eval () {
    printf '%s\n' "$1"
    read 'cont?Continue? [y/N] '
    [[ "${cont}" == 'y' || "${cont}" == 'Y' ]] || return 1
    eval "$1"
}

# Rsync wrapper.
#
# Synopsis:
#   sync SRC DST
#
# Description:
#   SRC         The source directory.
#   DST         The destination directory.
sync () {
    confirm_eval "rsync --del -vrlpt '${1}' '${ruser}@${rhost}:${2}'"
}

# === MAIN SCRIPT ==============================================================

# Pull the code repository.
printt 'BEGIN GIT PULL (CODE)'
git pull
printt 'END GIT PULL (CODE)'

# Pull the content repository.
printt 'BEGIN GIT PULL (CONTENT)'
git -C "${hugo_content}" pull
printt 'END GIT PULL (CONTENT)'

# Generate the info.txt file.
printf "${info_template}" "$(hugo version)" "$(date -Iseconds)" > "${hugo_info_txt}"
printf 'Repository CODE:    %s\n' "$(git describe --always --dirty='*')" >> "${hugo_info_txt}"
printf 'Repository CONTENT: %s\n' "$(git -C "${hugo_content}" describe --always --dirty='*')" >> "${hugo_info_txt}"

# Remove old builds.
printt 'BEGIN REMOVE OLD BUILDS'
confirm_eval "rm -rf ${hugo_public}"
confirm_eval "rm -rf ${hugo_public_dft}"
printt 'END REMOVE OLD BUILDS'

# Build site.
printt 'BEGIN HUGO (PUB)'
hugo --environment "production" --minify --destination "${hugo_public}"
echo '*' > "${hugo_public}/.gitignore"
printt 'END HUGO (PUB)'

# Build site with drafts enabled.
printt 'BEGIN HUGO (DFT)'
hugo --buildDrafts --environment "production" --minify --destination "${hugo_public_dft}"
echo '*' > "${hugo_public_dft}/.gitignore"
printt 'END HUGO (DFT)'

# Sync the site to its webroot.
printt 'BEGIN RSYNC'
sync "$hugo_public" "$rpath"
printt 'END RSYNC'

# Sync the site with drafts enabled to its webroot.
printt 'BEGIN RSYNC (DFT)'
sync "$hugo_public_dft" "$rpath_dft"
printt 'END RSYNC (DFT)'
