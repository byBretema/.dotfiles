

###############################################################################
### GIT  -- Helpers
###############################################################################

function __gs_output_format() {

    # Get directory name as param to print the header
    if [[ $# -lt 1 ]]; then
        echo "-- Expected dir name"
        return
    fi
    local dir=$1; shift


    # Pipeline support
    local msg=""
    if [[ -p /dev/stdin ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            msg+="$line\n"
        done
    fi

    # Don't print on certain outputs (no changes, no entries, already up to date, ...)
    [[ -z "$msg" ||
       "$msg" =~ "No stash entries found." ||
       "$msg" =~ "No local changes to save" ||
       "$msg" =~ "Everything up-to-date" ||
       "$msg" =~ "Already up to date." ||
       "$msg" =~ "nothing to commit, working tree clean"
    ]] && return

    # Print
    echo
    echo '=============================='
    echo '-> '${dir:u}
    echo '=============================='
    echo $msg
}
