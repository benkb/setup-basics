#!/bin/sh

# Helper/Utilities for working with tmux
#
# Usage: [--|- Options] <Command> [args]
#
# Options:
#   --help        show help
#
# Commands:
#   is 
#       up        is tmux running
#       inside    is this command called from inside a tmux terminal
#
#   list <args>     args: <win>|<sess>
#   ls <opts>       short for list sess
#   lw <opts>       short for list win
#       win         
#           ls 
#       sess

prn(){ printf "%s" $@; }
info(){ echo "$@" >&2;  }
die(){ echo "$@" >&2; exit 1; }

help(){ perl -ne 'print "$1\n" if /^\s*#\s+(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2; }
usage(){ help | grep Usage  ; die "or: --help" ; }


absdir(){ 
    local fso="${1:-}"
    [ -n "$fso" ] || die "Err: no filesystem object (file/dir)"
    if [ -f "$fso" ] ; then (cd "$(dirname "$fso" 2>/dev/null)" && pwd -P)
    elif [ -d "$fso" ] ; then (cd "$fso" 2>/dev/null && pwd -P)
    else die "Err: invalid filesystem object (file/dir) under $fso"
    fi
}

tmuxutil__is_up(){
    if tmux info > /dev/null ; then
        echo tmux is running
        return 0
    else
        info "Warn: tmux is not running"
        return 1
    fi
}

tmuxutil__is_inside(){

    tmuxutil__is_up > /dev/null || die "Err: tmux is not running"

    [ -z ${TERM_PROGRAM+x} ] && die "Err: cannot check for TERM_PROGRAM, maybe tmux is too old"

    if [ "$TERM_PROGRAM" = tmux ]; then
        echo 'Inside tmux'
        return 0
    else
        info 'Not inside tmux'
        return 1
    fi
}
tmuxutil__cmd_get(){

    local arg
    local opt_session
    while [ $# -gt 0 ] ; do
        case "$1" in
            -*) die "Err: invalid option '$1'";;
            *) arg="$1"; shift; break ;;
        esac
        shift
    done 

    tmuxutil__is_up > /dev/null 2>&1 || die "Err: tmux is not running"

    if [ -n "$arg" ] ; then
        case "$arg" in
            sess|session)  tmux display-message -p '#S';;
            win|window)  tmux display-message -p '#W';;
            sesswin|session:window)  tmux display-message -p '#S:#W';;
            *) die "Err: invalid arg '$arg'";;
        esac
    else
        tmux display-message -p '#S:#W'
    fi

}
tmuxutil__cmd_list(){

    local arg
    local opt_session
    while [ $# -gt 0 ] ; do
        case "$1" in
            -s|--sess) 
                opt_session="${2:-}"
                [ -n "$opt_session" ] || die "Err: session arg is empty"
                shift
                ;;
            -*) die "Err: invalid option '$1'";;
            *) arg="$1"; shift; break ;;
        esac
        shift
    done 

    [ -n "$arg" ] || die "Err(cmd_is): no arg"

    tmuxutil__is_up > /dev/null || die "Err: tmux is not running"

    case "$arg" in
        sess|session) tmux list-sessions ;;
        win|window)  
            {
            if [ -n "$opt_session" ] ; then
                tmux list-windows -t "$opt_session" 
            else
                tmux list-windows 
            fi
        } | perl -ne '/^\d+:\s+([\w\*\-\_\.\s]+)\s\(/; print "$1"'
        ;;
        *)
            die "Err: invalid arg '$arg'"
    esac
}

tmuxutil__cmd_is(){

    local arg
    local option
    while [ $# -gt 0 ] ; do
        case "$1" in
            -*) die "Err: invalid option '$1'";;
            *) arg="$1"; shift; break ;;
        esac
        shift
    done 


    [ -n "$arg" ] || die "Err(cmd_is): no arg"

    case "$arg" in
        up) tmuxutil__is_up ;;
        inside) tmuxutil__is_inside ;;
        *)
            die "Err: invalid account"
    esac
}

tmuxutil__main(){
    [ -n "${1:-}" ] || usage

    local cmd
    while [ $# -gt 0 ] ; do
        case "$1" in
            -h|--help) help ; exit 1 ;;
            -*) die "Err: invalid option '$1'";;
            *)  cmd="$1"; shift; break ;;
        esac
        shift
    done 

    [ -n "$cmd" ] || usage

    # cmds
    # new session
    # rename session

    case "$cmd" in
        is) tmuxutil__cmd_is "$@";;
        l|list) tmuxutil__cmd_list "$@";;
        ls) tmuxutil__cmd_list "$@" 'sess';;
        lw) tmuxutil__cmd_list "$@" 'win';;
        get) tmuxutil__cmd_get "$@" ;;
        gw) tmuxutil__cmd_get "$@" 'win';;
        gs) tmuxutil__cmd_get "$@" 'sess';;
        *) die "Err: invalid command '$cmd'" ;; 
    esac

}



[ -n "${MODULINO:-}" ] || tmuxutil__main "$@"
