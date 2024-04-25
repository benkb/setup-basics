## ALIASES
# In profile only essential commands
test -f '/usr/local/opt/vim/bin/vim' && alias vim='/usr/local/opt/vim/bin/vim'

# Everything else in in aliases.sh and aliases.fish etc in $HOME/kit/aliases/...

# dir constants
#
alias chmox='chmod 0755'
alias findi='find . -iname'

alias ,xargs='xargs -r0 -I {} '

alias ,more='more -R'

test -f $HOME/.sbin/abspath.sh && alias abspath="dash $HOME/.sbin/abspath.sh"
test -f $HOME/.sbin/ack.pl && alias ack="perl $HOME/.sbin/ack.pl"
test -f $HOME/.sbin/rename.pl && alias rename="perl $HOME/.sbin/rename.pl"
