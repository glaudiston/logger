#!/usr/bin/env bash

LOGGER_PATH="$(dirname "$(realpath "$BASH_SOURCE")")/logger.sh"
if [[ -f "$LOGGER_PATH" ]]; then
    . "$LOGGER_PATH"
else
    echo "Error: logger.sh not found at $LOGGER_PATH"
    exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

assert_log() {
    local func=$1
    local msg=$2
    local pattern=$3
    
    echo -n "Testing [$func] with message '$msg'... "
    local output
    output=$($func "$msg" 2>&1)
    
    if echo "$output" | grep -q "$pattern"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected pattern: $pattern"
        echo "  Actual output: $output"
        return 1
    fi
}

echo "--- Starting Logger Test Suite ---"

# 1. Test Basic Log Levels
assert_log "debug" "This is a debug message" "[DEBUG]"
assert_log "info"  "This is an info message"  "[INFO]"
assert_log "warn"  "This is a warning message"  "[WARN]"
assert_log "error" "This is an error message"    "[ERROR]"

# 2. Test JSON Output
echo -n "Testing JSON encoding... "
JSON_OUT=$(info "json test" 2>&1)
# We expect: {"level":"info","data":"json test"}
if echo "$JSON_OUT" | grep -q '"level":"info"' && echo "$JSON_OUT" | grep -q '"data":"json test"'; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Output: $JSON_OUT"
fi

# 3. Test Error Stack Trace
echo -n "Testing Error Backtrace... "
ERR_OUT=$(error "critical failure" 2>&1)
if echo "$ERR_OUT" | grep -q '"stack":' && echo "$ERR_OUT" | grep -q 'backtrace'; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Output: $ERR_OUT"
fi

echo "--- Test Suite Complete ---"
