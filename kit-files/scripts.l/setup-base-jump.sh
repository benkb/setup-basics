set -u

USAGE='-reset jump|base|all'


HOMEBASE="$HOME/base"
BASEJUMP="$HOMEBASE/jump"

MOUNTDIR="$HOME/mounts"

HOMEBASE="$HOME/base"

die () { echo "$@" 1>&2; exit 1; }

do_reset=''
while [ $# -gt 0 ] ; do
   case "$1" in
      -reset) 
         if [ -n "${2:-}" ] ; then
            do_reset="${2}"
            shift
         else
            die "Err: not enough args for -reset"
         fi
         ;;
      -h|-help|--help) die "usage: $USAGE" ;;
      -*) die "Err: invalid option" ;;
      *) break ;;
   esac
   shift 
done

case "$do_reset" in 
   base) echo "Err: please reset ~/base manually" ;;
   jump) rm -rf "$BASEJUMP" ;;
   all)
      rm -rf "$HOMEBASE" 
      rm -rf "$BASEJUMP" 
      ;;
esac

mkdir -p "$BASEJUMP"

HEREDIR="$(dirname "$0")"

BASELIB="$HEREDIR/baselib.sh"
if [ -f "$BASELIB" ] ; then
   . "$BASELIB"
else
   die "Err: script '$BASELIB' missing"
fi

baselib__link2target "$HOMEBASE" "$HOME" 'b'
baselib__link2target "$BASEJUMP" "$HOMEBASE" 'j'
baselib__link2target "$HOMEBASE" "$BASEJUMP" 'base'

for d in "$HOME"/* ; do
   [ -d "$d" ] || continue
   bd="$(basename "$d")"
   case "$bd" in
      [A-Z]*) baselib__link2target "$d" "$BASEJUMP" ;;
      *) : ;;
   esac
done

for d in "$HOME/."* ; do
   bd="$(basename "$d")"
   dotname="${bd#*.}"
   case "$bd" in
      '.'|'..') continue ;;
      *) 
         baselib__link2target "$d" "$BASEJUMP" 
         baselib__link2target "$d" "$BASEJUMP" "dot$dotname" 
         ;;
   esac
done


if [ -d "$MOUNTDIR" ] ; then
   baselib__link2target "$MOUNTDIR" "$BASEJUMP"
      
   for d in "$MOUNTDIR"/* ; do
      [ -d "$d" ] || continue
      bd="$(basename "$d")"
      baselib__link2target_plus "$d" "$BASEJUMP"
   done
fi


if [ -d "$HOMEBASE" ] ; then

   for d in "$HOMEBASE"/* ; do
      [ -d "$d" ] || continue
      baselib__link2target "$d" "$BASEJUMP"
   done
fi
