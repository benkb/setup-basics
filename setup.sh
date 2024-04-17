set -u

HOMEBASE="$HOME/base"
BASEJUMP="$HOMEBASE/jump"

CWD="$PWD"

mkdir -p "$HOMEBASE"
mkdir -p "$BASEJUMP"

mkdir -p "$BASEJUMP"
for bd in "$USER" 'local' 'bin' 'config' 'vim' 'opam' 'cargo' 'go' ; do 
   d="$HOME/.$bd"
   mkdir -p "$d"
   rm -f "$BASEJUMP/.$bd"
   ln -s "$d" "$BASEJUMP/.$bd"
done

for d in  "$HOME"/* ; do
   [ -d "$d" ] || continue
   bd="${d##*/}"
   case "$bd" in
      [A-Z]*)
         rm -f "$BASEJUMP"/"$bd"
         ln -s "$d" "$BASEJUMP"/"$bd"
         ;;
      *) : ;;
   esac
done

PWDBASE="$(basename "$PWD")"
rm -f "$BASEJUMP"/"$PWDBASE"
ln -s "$PWD" "$BASEJUMP"/"$PWDBASE"

echo ok
