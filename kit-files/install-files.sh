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
DOTFILES=
case "$SCRIPTDIR_NAME" in 
    *-files)     
        case "$DIR_TYPE" in
            dot) DOTFILES=1 ;;
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
    local target_item="${2:-}"
    [ -n "$target_item" ] || die "Err: no target_item"

    local target="$HOMEFOLDER/$target_item"

    remove_target "$target"
    ln -s "$source" "$target"

    if [ -n "$DOTFILES" ] ; then
        remove_target "${HOME}/.${target_item}"
        ln -s "$source" "${HOME}/.${target_item}"
    fi
}


for i in "$PWD"/* ; do
    [ -f "$i" ] || [ -d "$i" ] || continue 

	bi="${i##*/}"

    case "$bi" in $SCRIPTNAME|README*) continue ;; *) : ;; esac

    target_name="${bi%.*}"


    if [ -f "$i" ] ; then
    	link_to_target "$i" "${bi}"
        if [ -n "$DOTFILES" ]; then
            rm -f "${BASEJUMP}/.${bi}"
            ln -s "$i" "${BASEJUMP}/.${bi}"
        else
            rm -f "${BASEJUMP}/${bi}"
            ln -s "$i" "${BASEJUMP}/${bi}"
        fi
	elif [ -d "$i" ] ; then
        case "$target_name" in
            dot-home) : ;;
            *-*)
                target_path="$(perl -e '($a)=@ARGV; print(join("/", reverse( map { (/^[A-Z]+$/)?$ENV{$_}:$_ } split("-", $a))))' "$target_name")" 
                target_folder="${target_path%/*}"
                mkdir -p "$HOMEFOLDER/$target_folder"
                if [ -n "$DOTFILES" ]; then
                    mkdir -p "$HOME/.$target_folder"
                    rm -f "${BASEJUMP}/.${target_folder}"
                    ln -s "$HOME/.$target_folder" "$BASEJUMP/.$target_folder"
                else
                    rm -f "${BASEJUMP}/${target_folder}"
                    ln -s "$HOMEFOLDER/$target_folder" "${BASEJUMP}/${target_folder}"
                fi
                ;;
            *) target_path="$target_name" ;;
        esac


        case "$bi" in
            dot-home)
                for ii in "$i"/* ; do 
                    [ -f "$ii" ] || [ -d "$ii" ] || continue 
                    bii="${ii##*/}"
                    rm -f "$HOME/.$bii"
                    ln -s "$ii" "$HOME/.$bii"
                    rm -f "$BASEJUMP/.$bii"
                    ln -s "$ii" "$BASEJUMP/.$bii"
                done
                ;;
            *.d) link_to_target "$i" "$target_path" ;;
            *)
                mkdir -p "$HOMEFOLDER/$target_path"
                [ -n "$DOTFILES" ] && mkdir -p "$HOME/.$target_path"
                for ii in "$i"/* ; do 
                    [ -f "$ii" ] || [ -d "$ii" ] || continue 
                    bii="${ii##*/}"
                    dotii="$target_path/$bii"
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
