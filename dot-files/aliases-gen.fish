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


# sourcing for environment variables and aliases

######## NONINTERACTIVE SHELL

if [ -f ~/.profile ] 
    . ~/.profile
else
    echo "Warn: ~/.profile not loaded" >&2
end

if [ -d $PROFILE__SHELLCONF_HOME ] 
    for confdir in $PROFILE__SHELLCONF_HOME/*
        [ -d $confdir ] || continue
        for shfile in $confdir/*.*sh 
            switch $shfile
                case '*.sh' '*.fish'
                    #echo source "$shfile"
                    [ -f $shfile ] && source $shfile 
            end
        end
    end
end


status is-interactive || return 0 


######## INTERACTIVE SHELL

if [ -d $PROFILE__ALIASES_HOME ] 
    for dir in $PROFILE__ALIASES_HOME/*
        [ -d $dir ] || continue
        for shfile in $dir/*.*sh ; do
            switch $shfile 
                case '*.sh' '*.bash'
                    #[ -f "$shfile" ] && echo source "$shfile"
                    [ -f $shfile ] && source $shfile
            end
        end
    end
end

### Generate Aliases

set non_script  'java*' 'log*' 'md' 'txt' 'conf' 'o' 'out' 'css' 'html' 'rkt' 'sml'  '' 'json' 'c'
#set omits  'md txt conf o out css html rkt sml json c'



function get_interp
    set ext $argv[1]
    switch $ext
        case $non_script
            return 1
        case rb
            echo 'ruby'
        case pl
            echo 'perl'
        case py
            echo python
        case 'sh' 'bash' 'dash'
            echo $ext
        case '*'
            echo "Warn: extension '$ext' not implemented, skip alias" >&2
            return 1
    end
end


for utilsdir in $HOME/kit/*
    [ -d $utilsdir ] || continue

    switch $utilsdir
        case '*utils'
            :
        case '*'
            continue
    end

    for scriptfile in $utilsdir/*
        [ -f $scriptfile ] || continue

        set bname (path basename $scriptfile)
        set name (string split -r -m1 . $bname)[1]
        set ext (string split -r -m1 . $bname)[2]

        set interp (get_interp $ext)
        if string length --quiet  $interp
            switch "$name" 
                case '_*' 'lib*'
                    continue
                case '*'
                    alias $name="$interp $scriptfile"
            end
        end
    end
end
        

# posh: posix compatible
alias mrsh '~/bin/mrsh'

#binsh: dash compatible - posix  + local scoping
alias binsh 'dash'

#shell: sane bash (binsh + arrays)
alias yash  '/usr/local/bin/yash'


#for bindir in "$HOME/.bin" "$HOME/.$USER/bin" "$HOME/.$USER/utils"
#    if test -d "$bindir" 
#        for bin in "$bindir"/*.sh
#            test -f $bin || continue
#            set bf (basename $bin .sh)
#            alias "$bf"="/bin/sh $bin"
#        end
#    end
#end

