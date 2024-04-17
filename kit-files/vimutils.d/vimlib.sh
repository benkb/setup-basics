# shellcheck shell=sh
# ignore SC3043: 'local' not POSIX
# shellcheck disable=SC3043

set -u

VIMLIB__PIPE_EXT='.vipipe'
VIMLIB__TMUX_SESS='VIOUT'

_say() {
	printf '%s' "$@"
	printf '\n'
}
_prn() { printf "%s" "$@"; }
_die() {
	echo "$@"
	exit 1
}
_absdir() { prn "$(
	cd "$(dirname -- "${1:-}")" >/dev/null
	pwd -P
)"; }

shtdlib="$HOME/.$USER/utils/shtdlib.sh"
if [ -f "$shtdlib" ]; then
    . "$shtdlib"
else
    _die "Err: no lib under '$shtdlib'"
fi

vimlib__dir_token() {
	local dir="${1:-}"
	[ -n "$dir" ] || _die "Err: no dir"

    local absdir
    absdir="$(_absdir "$dir")" || die "Err: could not get absdir"
    [ -n "$absdir" ] || die "Err: absdir empty"

    local dirname=
    dirname="$(perl -e '($a)=@ARGV; $a =~ s/[^A-Za-z0-9]+/_/g; print $a;' "${dir##*/}")"

	local token
	token="$(shtdlib__md5sum "$absdir")" || die "Err: could not get md5sum"
    [ -n "$token" ] || die "Err: token is empty"

	prn "${dirname}-${token}"
}

vimlib__dir_token_pipe() {
	local dir="${1:-}"
	[ -n "$dir" ] || _die "Err: no dir"

    local dir_token
    dir_token="$(vimlib__dir_token "$dir")" || die "Err: could not get dir_token"
    [ -n "$dir_token" ] || die "Err: dir_token empty"

	[ -n "${VIMLIB__PIPE_EXT}" ] || die "Err: VIMLIB__PIPE_EXT empty"
	prn "${dir_token}${VIMLIB__PIPE_EXT}"
}

