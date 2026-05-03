#!/bin/bash
#
# A event-driven logger coded in bash
# depends on
# github.com/glaudiston/pragma_once: allow avoid import overhead
# github.com/glaudiston/event-driven: event pub-sub implementation
# github.com/glaudiston/backtrace: stack-trace detection implementation
# github.com/glaudiston/termsdk: ansi term code to TUI features like screen-buffers, cursor control, colors, etc.
# https://github.com/jqlang/jq: jqlang allows encode/decode and query json

. $(dirname $(realpath $BASH_SOURCE))/pragma_once/bash/pragma_once.sh || return 0 # if already loaded just return
. $(dirname $(realpath $BASH_SOURCE))/backtrace/bash/backtrace.sh
. $(dirname $(realpath $BASH_SOURCE))/event-driven/bash/event.sh
. $(dirname $(realpath $BASH_SOURCE))/termsdk/ansi_term_codes.sh

log_observer_json_stderr()
{
    shift # Remove the topic name ('LOG')
    local IFS='	'
    local level="${1,,}"
    shift # Remove the level (e.g., 'info'), leaving only the message in $@
    
    local TRACE=""
    [ "$level" == "error" ] && TRACE=", \"stack\": $(backtrace | jq -Rs)";
    
    echo -e "{ \"level\": \"$level\", \"data\": $(jq -Rs <<<"$*')${TRACE}"}" >&2
}

log_observer_stderr()
{
    shift # Remove the topic name ('LOG')
    local IFS='	'
    local level=$1
    shift # Remove the level, leaving only the message in $@
    
    local color=""
    [ "$level" == "error" ] && color="$TERM_COLOR_RED"
    
    echo -e "[${color}$level${TERM_COLOR_RESET}] $@" >&2
    [ "$level" == "error" ] && backtrace >&2
}

subscribe LOG log_observer_stderr
subscribe LOG log_observer_json_stderr

debug(){ publish LOG debug "$*"; }
info (){ publish LOG info  "$*"; }
warn (){ publish LOG warn  "$*"; }
error(){ publish LOG error "$*"; }

