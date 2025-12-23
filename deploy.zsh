#!/bin/zsh

PUB_DIR="${WWW_TIFRUEH_SRC}/public/pub/"
DFT_DIR="${WWW_TIFRUEH_SRC}/public/dft/"

printt () {
    title="=== ${1} "
    echo "${(r:80::=:)title}"
}

install () {
    RSYNC_CMD="rsync --del -vrlpt '${2}' '${3}'"
    printt "BEGIN RSYNC ${1}"
    printf '%s\n' "$RSYNC_CMD"
    read 'CONT?Continue? [y/N] '
    [[ "$CONT" != 'y' ]] && return
    eval "$RSYNC_CMD"
    printt "END RSYNC ${1}"
}

printt 'BEGIN GIT PULL (CODE)'
git -C "${WWW_TIFRUEH_SRC}" pull
printt 'END GIT PULL (CODE)'

echo ''

printt 'BEGIN GIT PULL (CONTENT)'
git -C "${WWW_TIFRUEH_SRC}/content" pull
printt 'END GIT PULL (CONTENT)'

echo ''

printt 'BEGIN HUGO (PUB)'
hugo --source "${WWW_TIFRUEH_SRC}" --destination "${PUB_DIR}"
printt 'END HUGO (PUB)'

echo ''

printt 'BEGIN HUGO (DFT)'
hugo --buildDrafts --source "${WWW_TIFRUEH_SRC}" --destination "${DFT_DIR}"
printt 'END HUGO (DFT)'

echo ''

install 'PUB' "${PUB_DIR}" "${WWW_TIFRUEH_DST_PUB}"

echo ''

install 'DFT' "${DFT_DIR}" "${WWW_TIFRUEH_DST_DFT}"
