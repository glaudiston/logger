#!/bin/bash
#
# A event-driven logger coded in bash
# depends on
# github.com/glaudiston/pragma_once: avoid import overhead
# github.com/glaudiston/event-driven: event pub-sub implementation
# github.com/glaudiston/backtrace: stack-trace detection implementation
# github.com/glaudiston/termsdk: ansi term code to TUI features like screen-buffers, cursor control, colors, etc.
# https://github.com/jqlang/jq: jqlang allows encode/decode and query json

. $(dirname $(realpath $BASH_SOURCE))/pragma_once/bash/import_bash.sh;
import_bash <<-EOF
	./backtrace/bash/backtrace.sh
	./event-driven/bash/event.sh
	./termsdk/ansi_term_codes.sh
EOF

log_observer_json_stderr()
{
    # The event-driven lib passes: Topic, Hash, Timestamp, Payload...
    shift 3 # ignore topic, hash, and timestamp
    
	declare -a payload=( ${1,,} );
    local level=${payload[0]} # First word of payload is the level
    
    local msg="${payload[@]:1}"
    local TRACE=""
    [ "$level" == "error" ] && TRACE=", \"stack\": $(backtrace | jq -Rs)";
    
    jq -cn \
	--arg level "$level" \
	--arg msg "$msg" \
	'{level:$level,"data":$msg'"$TRACE"'}' >&2
}

log_observer_stderr()
{
    # The event-driven lib passes: Topic, Hash, Timestamp, Payload...
    shift 3 # ignore topic, hash, and timestamp
    
    local payload=( $1 )
    local level="${payload[0],,}" # Lowercase the first element (the level)
    local msg="${payload[@]:1}"    # Join the remaining elements as the message
    
    local color=""
    [ "$level" == "error" ] && color="$TERM_COLOR_RED"
    
    # Output: [LEVEL] message
    echo -e "[${color}${level^^}${TERM_COLOR_RESET}] $msg" >&2
    [ "$level" == "error" ] && backtrace >&2
}

subscribe LOG log_observer_stderr
subscribe LOG log_observer_json_stderr

# Publish as: "level message"
debug(){ publish LOG "debug $*"; }
info (){ publish LOG "info  $*"; }
warn (){ publish LOG "warn  $*"; }
error(){ publish LOG "error $*"; }
