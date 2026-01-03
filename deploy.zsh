#!/bin/zsh

# = EXTERNAL VARIABLES =========================================================
#
# WWW_TIFRUEH_HUGO      Path to the hugo root.
# WWW_TIFRUEH_USR       User to which to rsync.
# WWW_TIFRUEH_HEADLESS  Set to some value to run non-interactively.
# WWW_TIFRUEH_WWW       Path to the webserver root.
# WWW_TIFRUEH_WWW_DFT   Path to the webserver root (drafts).
#
# ==============================================================================

# = INTERNAL VARIABLES =========================================================

hugo="${WWW_TIFRUEH_HUGO}"
hugo_public="${hugo}/public/pub/"
hugo_public_dft="${hugo}/public/dft/"
hugo_content="${hugo}/content/"
hugo_info_txt="${hugo}/static/info.txt"
www="${WWW_TIFRUEH_WWW}"
www_dft="${WWW_TIFRUEH_WWW_DFT}"

info_template="info.txt
========

Hugo Information
----------------
Hugo version: %s
Build started at: %s

Version Information
-------------------
"

if [ -n "$WWW_TIFRUEH_USR" ]; then
    rsync_prefix="sudo -u ${WWW_TIFRUEH_USR} "
else
    rsync_prefix=""
fi

# = FUNCTIONS ==================================================================

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
    if [[ -z "${WWW_TIFRUEH_HEADLESS}" ]]; then
        printf '%s\n' "$1"
        read 'cont?Continue? [y/N] '
        [[ "${cont}" == 'y' || "${cont}" == 'Y' ]] || return 1
    fi
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
    confirm_eval "${rsync_prefix}rsync --del -vrlpt '${1}' '${2}'"
}

# = MAIN SCRIPT ================================================================

# Pull the code repository.
printt 'BEGIN GIT PULL (CODE)'
git -C "${WWW_TIFRUEH_HUGO}" pull
printt 'END GIT PULL (CODE)'

# Pull the content repository.
printt 'BEGIN GIT PULL (CONTENT)'
git -C "${hugo_content}" pull
printt 'END GIT PULL (CONTENT)'

# Generate the info.txt file.
printf "${info_template}" "$(hugo version)" "$(date -Iseconds)" > "${hugo_info_txt}"
printf 'Repository CODE:    %s\n' "$(git -C "${hugo}" describe --always --dirty='*')" >> "${hugo_info_txt}"
printf 'Repository CONTENT: %s\n' "$(git -C "${hugo_content}" describe --always --dirty='*')" >> "${hugo_info_txt}"

# Build site.
printt 'BEGIN HUGO (PUB)'
hugo --source "${hugo}" --destination "${hugo_public}"
printt 'END HUGO (PUB)'

# Build site with drafts enabled.
printt 'BEGIN HUGO (DFT)'
hugo --buildDrafts --source "${hugo}" --destination "${hugo_public_dft}"
printt 'END HUGO (DFT)'

# Sync the site to its webroot.
printt 'BEGIN RSYNC'
sync "$hugo_public" "$www"
printt 'END RSYNC'

# Sync the site with drafts enabled to its webroot.
printt 'BEGIN RSYNC (DFT)'
sync "$hugo_public_dft" "$www_dft"
printt 'END RSYNC (DFT)'
