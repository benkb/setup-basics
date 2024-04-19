# shellcheck shell=sh
# ignore SC3043: 'local' not POSIX
# shellcheck disable=SC3043
#
set -u

stdlib__HAS_REALPATH="$(command -v realpath)"
stdlib__HAS_MD5SUM="$(command -v md5sum)"

_prn() { printf "%s" "$@"; }
_die() {
	echo "$@"
	exit 1
}

stdlib__hello(){ 
    echo 'Hello from stdlib, test successfully'
}

stdlib__absdir(){ 
    local fso="${1:-}"
    [ -n "$fso" ] || die "Err: no filesystem object (file/dir)"
    if [ -f "$fso" ] ; then (cd "$(dirname "$fso" 2>/dev/null)" && pwd -P)
    elif [ -d "$fso" ] ; then (cd "$fso" 2>/dev/null && pwd -P)
    else die "Err: invalid filesystem object (file/dir) under $fso"
    fi
}

stdlib__realpath() {
	local path="${1:-}"
	[ -n "$path" ] || _die "Err(stdlib__realpath): no path given"

	if [ -n "$stdlib__HAS_REALPATH" ] ; then
		realpath "$path"
	else
		perl -MCwd -e 'print(Cwd::abs_path($ARGV[0]))' "${path}"
	fi
}

stdlib__md5sum() {
	local string="${1:-}"
	[ -n "$string" ] || _die "Err(stdlib__md4sum): no string given"

	if [ -n "$stdlib__HAS_MD5SUM" ] ; then
		_prn "$string" | md5sum | cut -f1 -d" "
	else
		perl -MDigest::MD5 -e 'print(Digest::MD5::md5_hex($ARGV[0]))' "$string"
	fi
}


