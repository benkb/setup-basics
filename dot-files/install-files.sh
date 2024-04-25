#!/bin/sh
#
set -u

HOMEBASE="$HOME/base"

BASEJUMP="$HOMEBASE/jump"
FILESBASE="$HOMEBASE/files"

die () { echo "$@"; exit 1; }

SCRIPTNAME="${0##*/}"
SCRIPTDIR="$(cd "${0%/*}" ; pwd -P ;)"

SCRIPTDIR_NAME="${SCRIPTDIR##*/}"

DIR_TYPE="${SCRIPTDIR_NAME%-*}"

BASEFOLDER=
IS_DOTFILES=
case "$SCRIPTDIR_NAME" in 
    *-files)     
        case "$DIR_TYPE" in
            dot) IS_DOTFILES=1 ;;
            *) : ;;
        esac
        BASEFOLDER="$HOMEBASE/${DIR_TYPE}" 
        ;;
    *)  die "Err: '$SCRIPTDIR_NAME' does not look a files folder" ;;
esac


mkdir -p "$BASEJUMP"
mkdir -p "$BASEFOLDER"

mkdir -p "$FILESBASE"
rm -f "$FILESBASE/$SCRIPTDIR_NAME"
ln -s "$SCRIPTDIR" "$FILESBASE/$SCRIPTDIR_NAME"

rm -f "$BASEJUMP"/files
ln -s "$FILESBASE" "$BASEJUMP"/files

rm -f "$BASEJUMP/$SCRIPTDIR_NAME"
ln -s "$SCRIPTDIR" "$BASEJUMP/$SCRIPTDIR_NAME"

rm -f "$BASEJUMP/$DIR_TYPE"
ln -s "$BASEFOLDER" "$BASEJUMP/$DIR_TYPE"

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
    local target_basefolder="${2:-}"
    [ -n "$target_basefolder" ] || die "Err: target_basefolder "
    local target_item="${3:-}"
    [ -n "$target_item" ] || die "Err: no target_item"
    local is_dotfile="${4:-}"

    [ -d "$target_basefolder" ] || die "Err: basefolder does not exists"

    local target="$target_basefolder/$target_item"

    remove_target "$target"
    ln -s "$source" "$target"

    if [ -n "$IS_DOTFILES" ] || [ -n "$is_dotfile" ]  ; then
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
    	link_to_target "$i" "$BASEFOLDER" "${bi}"
        if [ -n "$IS_DOTFILES" ]; then
            rm -f "${BASEJUMP}/.${bi}"
            ln -s "$i" "${BASEJUMP}/.${bi}"
        else
            rm -f "${BASEJUMP}/${bi}"
            ln -s "$i" "${BASEJUMP}/${bi}"
        fi
	elif [ -d "$i" ] ; then
        # magic: fish-config -> config/fish; dot-HOME -> /home/baba/dot
        target_folder="$(perl -e '($a)=@ARGV; print(join("/", reverse( map { (/^[A-Z]+$/)?$ENV{$_}:$_ } split("-", $a))))' "$target_name")" 
        target_folder_parent="${target_folder%/*}"
        target_folder_top="${target_folder%%/*}"

        # Cover the basics: parent directories
        IS_DOTDIR=''
        case "$target_folder" in
            */*)
                case "$target_folder" in
                    /*/dot) IS_DOTDIR=1;; 
                    /*) die "Err: not supported yet '$target_folder'";;
                    *)
                        mkdir -p "$BASEFOLDER/$target_folder_parent"
                        if [ -n "$IS_DOTFILES" ]; then
                            mkdir -p "$HOME/.$target_folder_parent"
                            rm -f "${BASEJUMP}/.${target_folder_top}"
                            ln -s "$HOME/.$target_folder_top" "$BASEJUMP/.$target_folder_top"
                        else
                            rm -f "${BASEJUMP}/${target_folder_parent}"
                            ln -s "$BASEFOLDER/$target_folder_parent" "${BASEJUMP}/${target_folder_parent}"
                        fi
                    ;;
                esac
                ;;
            *) 
                target_folder="$target_name"
                target_folder_parent=''
            ;;
        esac


        case "$bi" in
            *.d)
                if [ -n "$IS_DOTDIR" ] ; then
                    rm -f "$BASEFOLDER/$bi"
                    ln -s "$i" "$BASEFOLDER/$bi"
                    for ii in "$i"/* ; do 
                        [ -f "$ii" ] || [ -d "$ii" ] || continue 
                        bii="${ii##*/}"
                        rm -f "$HOME/.$bii"
                        ln -s "$ii" "$HOME/.$bii"
                        rm -f "$BASEJUMP/.$bii"
                        ln -s "$ii" "$BASEJUMP/.$bii"
                    done
                else
                    mkdir -p "$BASEFOLDER/$target_folder"
                    [ -n "$IS_DOTFILES" ] && mkdir -p "$HOME/.$target_folder"
                    for ii in "$i"/* ; do 
                        [ -f "$ii" ] || [ -d "$ii" ] || continue 
                        bii="${ii##*/}"
                        dotii="$target_folder/$bii"
                        if [ -f "$ii" ] ; then 
                            link_to_target "$ii" "$BASEFOLDER" "$dotii"
                        elif [ -d "$ii" ] ; then 
                            case "$bii" in
                                *.d) die "Err: nested folders are not supported $ii, only folders.d" ;;
                                *) link_to_target "$ii" "$BASEFOLDER" "${dotii%.*}" ;;
                            esac
                        else
                            die "Err: not supported source path $ii"
                        fi
                    done
                fi
            ;;
            *) link_to_target "$i" "$BASEFOLDER" "$target_folder" ;;
        esac
	else
		echo "Warn: omit $i"
	fi
done
