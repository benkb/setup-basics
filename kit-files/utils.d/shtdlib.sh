# shellcheck shell=sh
# ignore SC3043: 'local' not POSIX
# shellcheck disable=SC3043
#
set -u

SHTDLIB__HAS_REALPATH="$(command -v realpath)"
SHTDLIB__HAS_MD5SUM="$(command -v md5sum)"

_prn() { printf "%s" "$@"; }
_die() {
	echo "$@"
	exit 1
}
_absdir() { prn "$(
	cd "$(dirname -- "${1:-}")" >/dev/null
	pwd -P
)"; }

shtdlib__realpath() {
	local path="${1:-}"
	[ -n "$path" ] || _die "Err(shtdlib__realpath): no path given"

	if [ -n "$SHTDLIB__HAS_REALPATH" ] ; then
		realpath "$path"
	else
		perl -MCwd -e 'print(Cwd::abs_path($ARGV[0]))' "${path}"
	fi
}

shtdlib__md5sum() {
	local string="${1:-}"
	[ -n "$string" ] || _die "Err(shtdlib__md4sum): no string given"

	if [ -n "$SHTDLIB__HAS_MD5SUM" ] ; then
		_prn "$string" | md5sum | cut -f1 -d" "
	else
		perl -MDigest::MD5 -e 'print(Digest::MD5::md5_hex($ARGV[0]))' "$string"
	fi
}


