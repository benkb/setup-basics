
if test -d /usr/local/share/vim/syntax
   export VIMRUNTIMEDIR=/usr/local/share/vim/syntax
else if test -d /usr/local//Cellar/vim/9.1.0150/share/vim/vim91
   export VIMRUNTIME=/usr/local//Cellar/vim/9.1.0150/share/vim/vim91
else
   echo "Warn could not set VIMRUNTIME" >&2
end
