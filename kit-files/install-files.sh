#!/bin/sh
#
set -u

HOMEBASE="$HOME/base"
BASEJUMP="$HOMEBASE/jump"
FILESDIR="$HOMEBASE/files"

die () { echo "$@"; exit 1; }

SCRIPTNAME="${0##*/}"
SCRIPTDIR="$(cd "${0%/*}" ; pwd -P ;)"

SCRIPTDIR_NAME="${SCRIPTDIR##*/}"

DIR_TYPE="${SCRIPTDIR_NAME%-*}"
DIR_FOLDER="${DIR_TYPE}s"
BASEFOLDER="$HOMEBASE/${DIR_FOLDER}"


HOMEFOLDER=
DOTFILE=
case "$SCRIPTDIR_NAME" in 
    *-files)     
        case "$DIR_TYPE" in
            dot) DOTFILE=1 ;;
            *) : ;;
        esac
        HOMEFOLDER="$HOME/${DIR_TYPE}" ;;
    *)  die "Err: '$SCRIPTDIR_NAME' does not look a files folder" ;;
esac

mkdir -p "$BASEJUMP"
mkdir -p "$HOMEFOLDER"
mkdir -p "$BASEFOLDER"

rm -f "$BASEFOLDER/$SCRIPTDIR_NAME"
ln -s "$SCRIPTDIR" "$BASEFOLDER/$SCRIPTDIR_NAME"

rm -f "$BASEJUMP/$SCRIPTDIR_NAME"
ln -s "$SCRIPTDIR" "$BASEJUMP/$SCRIPTDIR_NAME"

rm -f "$BASEJUMP/$DIR_FOLDER"
ln -s "$BASEFOLDER" "$BASEJUMP/$DIR_FOLDER"

rm -f "$BASEJUMP/$DIR_FOLDER"
ln -s "$BASEFOLDER" "$BASEJUMP/$DIR_FOLDER"

rm -f "$BASEJUMP/$DIR_TYPE"
ln -s "$HOMEFOLDER" "$BASEJUMP/$DIR_TYPE"


remove_target(){
    local target="${1:-}"
    [ -n "$target" ] || die "Err: no target"

    if [ -f "$target" ]; then
        rm -f "$target"
    elif [ -d "$target" ]; then
        if [ -L "$target" ] ; then
            rm -f "$target"
        else
            die "Err: the target '$target' is a directory, cannot remove"
        fi
    else
        rm -f "$target"
    fi
}

link_to_target(){
    local source="${1:-}"
    [ -n "$source" ] || die "Err: no source"
    local target="${2:-}"
    [ -n "$target" ] || die "Err: no target"

    remove_target "$target"
    ln -s "$source" "$target"

    local target_base="${target##*/}"

    rm -f "${BASEJUMP}/${target_base}"
    ln -s "$source" "${BASEJUMP}/${target_base}"

    if [ -n "$DOTFILE" ] ; then
        remove_target "${HOME}/.${target_base}"
        ln -s "$source" "${HOME}/.${target_base}"
    fi
}


for i in "$PWD"/* ; do
    [ -f "$i" ] || [ -d "$i" ] || continue 

	bi="${i##*/}"

    case "$bi" in $SCRIPTNAME|README*) continue ;; *) : ;; esac

    target_name="${bi%.*}"

    if [ -f "$i" ] ; then
    	link_to_target "$i" "${HOMEFOLDER}/${bi}"
	elif [ -d "$i" ] ; then
        homedot_targetdir=
        homedot_targetpath=
        target_path="$(perl -e '($a)=@ARGV; print(join("/", reverse( map { (/^[A-Z]+$/)?$ENV{$_}:$_ } split("-", $a))))' "$target_name")" 
        homedot_targetpath="${HOMEFOLDER}/${target_path}"
        targetdir="${target_path%/*}"
        homedot_targetdir="${HOMEFOLDER}/${targetdir}"
        #
        if [ "$homedot_targetpath" != "$homedot_targetdir" ] ; then
            mkdir -p "$homedot_targetdir"
        fi

        case "$bi" in
            *.d) link_to_target "$i" "$homedot_targetpath" ;;
            *)
                mkdir -p "$homedot_targetpath"
                for ii in "$i"/* ; do 
                    [ -f "$ii" ] || [ -d "$ii" ] || continue 
                    bii="${ii##*/}"
                    dotii="$homedot_targetpath/$bii"
                    if [ -f "$ii" ] ; then 
                        link_to_target "$ii" "$dotii"
                    elif [ -d "$ii" ] ; then 
                        case "$bii" in
                            *.d) link_to_target "$ii" "${dotii%.*}" ;;
                            *) die "Err: nested folders are not supported $ii, only folders.d" ;;
                        esac
                    else
                        die "Err: not supported source path $ii"
                    fi
                done
            ;;
        esac
	else
		echo "Warn: omit $i"
	fi
done
