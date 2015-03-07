#!/usr/bin/env bash
# /travis/bootstrap.sh
#
# Travis CI Script which downloads util.sh and sets up the script tree in
# the directory specified by -d. This script should be called with both -d and
# -s, -s being a relative path from public-travis-scripts.polysquare.org to
# a setup script which will set everything up once this command has finished
# running.
#
# This script will set the following environment variables:
# - POLYSQUARE_CI_SCRIPTS_DIR
#
# See LICENCE.md for Copyright information

while getopts "d:s:" opt "$@"; do
    case "$opt" in
    d) container_dir="$OPTARG"
       ;;
    s) setup_script="$OPTARG"
       ;;
    esac
done

: "${container_dir?'Must pass a path to a container with -d'}"
: "${setup_script?'Must pass the path to a setup script with -s'}"

>&2 mkdir -p "${container_dir}"

curl_command="curl -LSs --create-dirs --retry 999 --retry-max-time 0 -C -"

function _polysquare_install_program {
    local relative_src="$1"
    local prog_name="$2"

    which "${prog_name}" > /dev/null

    if [[ "$?" == "1" ]] ; then
        progs_base="public-travis-programs.polysquare.org"
        indent_src="${progs_base}/${relative_src}"
        indent_prog="${CONTAINER_DIR}/shell/bin/${prog_name}"

        >&2 mkdir -p "${CONTAINER_DIR}/shell/bin"
        eval "${curl_command}" "${indent_src}" | c++ -xc++ -o "${indent_prog}" -
        >&2 chmod +x "${indent_prog}"
    fi
}

function eval_and_fwd {
    eval "$1" && echo "$1"
}

eval_and_fwd "export CONTAINER_DIR=${container_dir};"
eval_and_fwd "export PATH=${CONTAINER_DIR}/shell/bin/:\${PATH};"

_polysquare_install_program indent/polysquare-indent.cpp polysquare_indent
_polysquare_install_program init_newline/polysquare-init-newline.cpp \
    polysquare_init_newline

# If this variable is specified, then there's no need to redownload util.sh
# so don't download it
if [ -z "${__POLYSQUARE_CI_SCRIPTS_BOOTSTRAP+x}" ] ; then
    >&2 mkdir -p "${POLYSQUARE_CI_SCRIPTS_DIR}"
    >&2 eval "${curl_command}" \
        "public-travis-scripts.polysquare.org/travis/util.sh" \
            -O "${POLYSQUARE_CI_SCRIPTS_DIR}/util.sh"
    
    POLYSQUARE_CI_SCRIPTS_DIR="${CONTAINER_DIR}/_scripts"
else
    POLYSQUARE_CI_SCRIPTS_DIR=$(dirname "${__POLYSQUARE_CI_SCRIPTS_BOOTSTRAP}")
fi

# Export POLYSQUARE_CI_SCRIPTS_DIR now that we've determined where our scripts
# are on the filesystem.
eval_and_fwd "export POLYSQUARE_CI_SCRIPTS_DIR=${POLYSQUARE_CI_SCRIPTS_DIR};"

if [ -z "${_POLYSQUARE_TESTING_WITH_BATS}" ] ; then
    eval_and_fwd "source ${POLYSQUARE_CI_SCRIPTS_DIR}/util.sh"
fi

# Now that we've set everything up, pass control to our setup script (remember
# that bash 4.3 is now in our PATH).
if [ -z "${__POLYSQUARE_CI_SCRIPTS_BOOTSTRAP+x}" ] ; then
    eval "${curl_command}" \
        "public-travis-scripts.polysquare.org/${setup_script}" | bash
else
    bash "${POLYSQUARE_CI_SCRIPTS_DIR}/${setup_script}"
fi

# Print a final \n

>&2 printf "\n"