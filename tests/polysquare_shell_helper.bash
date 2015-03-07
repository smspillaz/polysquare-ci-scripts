#!/usr/bin/env bash
# /tests/polysquare_shell_helper.bash
#
# Copies the shell sample project into a temporary directory and changes into
# it, running the shell setup script.
#
# See LICENCE.md for Copyright information

load polysquare_project_copy_helper

function polysquare_shell_setup {
    polysquare_project_copy_setup shell
}

function polysquare_shell_teardown {
    polysquare_project_copy_teardown
}