#!/bin/sh
#
#
HOMEBASE="$HOME/base"

BASEJUMP="$HOMEBASE/jump"
mkdir -p "$BASEJUMP"

DIRNAME="$(basename "$PWD")"

rm -f "$BASEJUMP/$DIRNAME"
ln -s "$PWD" "$BASEJUMP/$DIRNAME"

info(){ echo $@ >&2; }
die(){ echo $@ >&2; exit 1; }

link_to_target(){
    local source="${1:-}"
    [ -n "$source" ] || die "Err: no source"
    local target="${2:-}"
    [ -n "$target" ] || die "Err: no target"

    [ -e "$source" ] || {
        info "Warn: no valid source '$source'"
        return 1
    }

    local target_dir="$(dirname "$target")"
    [ -d "$target_dir" ] || {
        info "Warn: no valid target_dir '$target_dir'"
        return 1
    }
    
    
    rm -f "$target"

    if [ -L "$source" ] ; then
        cp -P "$source" "$target"
    else
        ln -s "$source" "$target"
    fi
}

MAINDIR=
case "$DIRNAME" in
    *-*-*) die "Err: please only one '-' dir '$DIRNAME'" ;;
    *-*)
        MAINDIR="${DIRNAME%-*}"s
        ;;
    *) die "Err: no dash dirname '$DIRNAME'";;
esac


mkdir -p "$HOMEBASE/$MAINDIR"
link_to_target "$PWD" "$HOMEBASE/$MAINDIR/$DIRNAME"

link_to_target "$HOMEBASE/$MAINDIR" "$BASEJUMP/$MAINDIR"


for d in "$PWD"/*; do
    [ -d "$d" ] || continue
    bd="${d##*/}"
    case "$bd" in
        *-*-*) 
            echo  "Info: skip multi dash dirname '$bd'"
            continue
            ;;
        *-*) 
            _maindir="${bd##*-}" 
            _subdir="${bd%-*}" ;;
        *) 
            echo  "Info: skip no dash dirname '$bd'"
            continue
            ;;
    esac

    homedir="$HOME/$_subdir"
    [ -d "$homedir" ] && link_to_target "$homedir" "$BASEJUMP/$_subdir" 

    mkdir -p "$HOMEBASE/$_maindir"

    link_to_target "$PWD" "$HOMEBASE/$_maindir/$bd"

    link_to_target "$HOMEBASE/$_maindir" "$BASEJUMP/$_maindir"
done



for fso in $HOME/.*; do
    [ -e "$fso" ] || continue

    fsod="${fso%/*}"
    fsob="${fso##*/}"

    [ "$fsod" = "$fsob" ] && {
        echo "something wrong with '$fso'"
        continue
    }
    
    case "$fsob" in
        .|..) echo "Invalid fsob '$fsob', skipping " 
            continue
            ;;
        $fsod)
            echo "something wrong with '$fso' ('$fsob' vs '$fsod'), skipping"
            continue
            ;;
        *)
    esac

    link_to_target "$fso" "$BASEJUMP/$fsob"

done

exit

for fso in $HOME/*; do
    [ -e "$fso" ] || continue

    fsod="${fso%/*}"
    fsob="${fso##*/}"
    
    [ "$fsod" = "$fsob" ] && {
        echo "something wrong with '$fso'"
        continue
    }

    case "$fsob" in
        [A-Z]*) link_to_target "$fso" "$BASEJUMP/$fsob" ;;
        *) : ;;
    esac
done


