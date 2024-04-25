#!/bin/sh
#
# check with `checkbashisms --posix` or with `posh`
#
set -u

HELP='A simple shell script template, possibly posix compatible'

USAGE='[-h|--help] [-v|--verbose] <file-input> '

prn(){ printf "%s" "$@"; }
info(){ echo "$@" >&2;  }
die(){ echo "$@" >&2; exit 1; }
stamp() { date +'%Y%m%d%H%M%S'; }

init(){
    SCRIPTBASE="${0##*/}"
    SCRIPTNAME="${SCRIPTBASE%.*}"
    SCRIPTDIR="$(cd $(dirname "$0" 2>/dev/null) && pwd -P)" || die "Err: could not set SCRIPTDIR"
    [ -n "$SCRIPTDIR" ] || die "Err: SCRIPTDIR is empty"
}

INPUT=
OPT_VERBOSE=
while [ $# -gt 0 ] ; do
    case "${1}" in
        -h|--help) echo "$HELP" >&2; die "Usage: $USAGE" >&2 ;;
        -v|--verbose) OPT_VERBOSE=1;;
        -*) die "Err: invalid opt $1, run --help";;
        *) INPUT="$1"; break;;
    esac
    shift
done

[ -n "$INPUT" ] || die "Usage: $USAGE" >&2

echo "OK: input $INPUT"
