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
    echo "Warn: ~/.profile not found" >&2
end

if [ -d "$PROFILE__SHELLCONF_HOME" ] 
    for confdir in $PROFILE__SHELLCONF_HOME/*
        [ -d "$confdir" ] || continue
        for shfile in $confdir/*.*sh 
            switch $shfile
                case '*.sh' '*.fish'
                    #[ -f "$shfile" ] && echo source $shfile 
                    [ -f "$shfile" ] && source $shfile 
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
                case '*.sh' '*.fish'
                    #[ -f "$shfile" ] && echo source "$shfile"
                    [ -f $shfile ] && source $shfile
            end
        end
    end
end


