#!/usr/bin/env bash
# /tests/polysquare_fresh_container_helper.bash
#
# Creates a fresh container dir, copying only the scripts directory
# from the old container
#
# See LICENCE.md for Copyright information

function polysquare_fresh_container_setup {
    # Create a new CONTAINER_DIR as a copy of the current one and move
    # the old one out of the way. This ensures taht when scripts
    # invoke bootstrap.sh, they will only use executables in the
    # copy of CONTAINER_DIR's path
    local temporary_container_directory=$(mktemp -d "${HOME}/.psq-cont.XXXXXX")

    # Move the container directory on top of temporary_container_directory
    # and then copy it back in place.
    #
    # This will ensure that that the tests are only modifying their own
    # copy of the container directory. The container directory must
    # always stay in the same place since the language installations often
    # have hardcoded references to it.
    rm -rf "${temporary_container_directory}"
    mv "${CONTAINER_DIR}" "${temporary_container_directory}"

    export _POLYSQUARE_FRESH_LAST_CONTAINER="${temporary_container_directory}"

    mkdir -p "${CONTAINER_DIR}"
    cp -rf "${temporary_container_directory}/_scripts" \
        "${CONTAINER_DIR}/_scripts"
    cp -rf "${temporary_container_directory}/shell" \
        "${CONTAINER_DIR}/shell"
    cp -rf "${temporary_container_directory}/_cache" \
        "${CONTAINER_DIR}/_cache"
}

function polysquare_fresh_container_teardown {
    __polysquare_delete_script_outputs

    # Restore cache before removing container copy
    local cache_backup=$(mktemp -d "/tmp/psq-cache.XXXXXX")
    rm -rf "${cache_backup}"

    mv "${CONTAINER_DIR}/_cache" "${cache_backup}"

    rm -rf "${CONTAINER_DIR}"
    mv "${_POLYSQUARE_FRESH_LAST_CONTAINER}" "${CONTAINER_DIR}"
    rsync -av "${cache_backup}/" "${CONTAINER_DIR}/_cache/" > /dev/null 2>&1
    rm -rf "${cache_backup}"
    unset _POLYSQUARE_FRESH_LAST_CONTAINER
}