# Thougths about where/how to manage/store fish configs
# - fish autoload of configs and scripts via ~/.config/fish/conf.d
# - autoload has negative impact when in non-interactive mode (scripting)
# - control the inclusion manually here in ~/.config/fish/config.fish

# start in insert mode
fish_vi_key_bindings insert

set -gx GPG_TTY (/usr/bin/tty)

### Interactive Shell Only
# if this called during the init of a script its time to go
# was not a good idea when using fish from ssh
# status --is-login || exit 

[ -e $HOME/.profile ]  && source $HOME/.profile

#exit

# search and source fish aliases
[ -f "$SHUTILS_HOME/_aliases.sh" ] && source "$SHUTILS_HOME/_aliases.sh"

for fishdir in $ALIASES $MORECONFIGS "$HOME/.$USER/fishconf"
   if [ -d $fishdir ] 
      for fishfile in $fishdir/*.*sh ; 
         switch "$fishfile"
            case '*'.fish
               [ -f $fishfile ] && source  $fishfile
            case '*'.sh
               [ -f $fishfile ] && source $fishfile
         end
      end
   end
end

for fishdir in $HOME/kit/vimutils $HOME/kit/utils
   if [ -d $fishdir ] 
      for shfile in $fishdir/*.*sh ; 
         switch "$shfile"
             case '_*'
                 continue
            case '*'.fish
                set name (basename $shfile .fish)
               [ -f $shfile ] &&  alias $name="fish $shfile"
            case '*'.sh
                set name (basename $shfile .sh)
               [ -f $shfile ] &&  alias $name="sh $shfile"
         end
      end
   end
end





# posh: posix compatible
alias posh '~/bin/mrsh'

#binsh: dash compatible - posix  + local scoping
alias binsh 'dash'

#shell: sane bash (binsh + arrays)
alias shell '/usr/local/bin/yash'


for bindir in "$HOME/.bin" "$HOME/.$USER/bin" "$HOME/.$USER/utils"
    if test -d "$bindir" 
        for bin in "$bindir"/*.sh
            test -f $bin || continue
            set bf (basename $bin .sh)
            alias "$bf"="/bin/sh $bin"
        end
    end
end


# >>> coursier install directory >>>
set -gx PATH "$PATH:/Users/ben/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
