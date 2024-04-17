# dir constants
#
#echo loading aliases

alias ,chmox='chmod 0755'
alias ,findi='find . -iname'

alias ,xargs='xargs -r0 -I {} '

alias ,b="bash"

#alias ,cwd='printf "%q\n" "$(pwd)" | pbcopy'
alias ,cwd='perl -MCwd  -e  "print(Cwd::abs_path())" | pbcopy && pbpaste' 

alias ,more='more -R'

alias ,shfmt='shfmt -i 3 -w'


# ack --follow: follow symlinks
alias ,grep="/usr/bin/env perl $DOTLOCAL_BIN/ack --follow "

alias ,rename="/usr/bin/perl $DOTLOCAL_BIN/rename"

alias smlnj='/usr/local/smlnj/bin/sml'

alias bob="java -jar $HOME/bin/bob.jar"

#alias vv='mvim --servername VIM --remote-tab'
alias vv='nvim --server ~/.cache/nvim/server.pipe --remote'
