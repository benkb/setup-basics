#!/bin/sh
#
set -u

HOMEBASE="$HOME/base"
BASEJUMP="$HOMEBASE/jump"
FILESDIR="$HOMEBASE/files"

PWDABS="$(cd "${PWD}" ; pwd -P ;)"

mkdir -p "$BASEJUMP"

die () { echo "$@"; exit 1; }

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

    case "$target_base" in
        .*)
            rm -f "${BASEJUMP}/${target_base}"
            ln -s "$source" "${BASEJUMP}/${target_base}"
        ;;
        *) : ;;
    esac
}


handle_files_dir(){
    local cwd="${1:-}"
    [ -n "$cwd" ] || die "Err: no cwd"

    local homefolder="${2:-}"
    [ -n "$homefolder" ] || die "Err: no homefolder"

    for i in "$cwd"/* ; do
        [ -f "$i" ] || [ -d "$i" ] || continue 

        local bi="${i##*/}"

        case "$bi" in README*) continue ;; *) : ;; esac

        local target_name="${bi%.*}"

        if [ -f "$i" ] ; then
            link_to_target "$i" "${homefolder}${bi}"
        elif [ -d "$i" ] ; then
            local homedot_targetdir=
            local homedot_targetpath=
            local target_path="$(perl -e '($a)=@ARGV; print(join("/", reverse( map { (/^[A-Z]+$/)?$ENV{$_}:$_ } split("-", $a))))' "$target_name")" 
            local homedot_targetpath="${homefolder}${target_path}"
            local targetdir="${target_path%/*}"
            local homedot_targetdir="${homefolder}${targetdir}"
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
                        local bii="${ii##*/}"
                        local dotii="$homedot_targetpath/$bii"
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
}


for SCRIPTDIR in "$PWDABS"/* ; do
    [ -d "$SCRIPTDIR" ] || continue

    SCRIPTDIR_NAME="${SCRIPTDIR##*/}"

    DIR_TYPE="${SCRIPTDIR_NAME%-*}"
    DIR_FOLDER="${DIR_TYPE}s"
    BASEFOLDER="$HOMEBASE/${DIR_FOLDER}"

    HOMEFOLDER=
    case "$SCRIPTDIR_NAME" in 
        dot-files)   HOMEFOLDER="$HOME/." ;;
        *-files)     HOMEFOLDER="$HOME/${DIR_TYPE}/" ;;
        *)      
            echo "Info: skip '$SCRIPTDIR'"
            continue
        ;;
    esac

    mkdir -p "$HOMEFOLDER"
    mkdir -p "$BASEFOLDER"


    rm -f "$BASEFOLDER/$SCRIPTDIR_NAME"
    ln -s "$SCRIPTDIR" "$BASEFOLDER/$SCRIPTDIR_NAME"

    rm -f "$BASEJUMP/$SCRIPTDIR_NAME"
    ln -s "$SCRIPTDIR" "$BASEJUMP/$SCRIPTDIR_NAME"

    rm -f "$BASEJUMP/$DIR_FOLDER"
    ln -s "$BASEFOLDER" "$BASEJUMP/$DIR_FOLDER"

    handle_files_dir "$SCRIPTDIR" "$HOMEFOLDER"

done

