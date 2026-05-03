#!/usr/bin/env bash

# Load the logger
# Using absolute path to ensure it works regardless of where the script is called from
LOGGER_PATH="$(dirname "$(realpath "$BASH_SOURCE")")/logger.sh"
if [[ -f "$LOGGER_PATH" ]]; then
    . "$LOGGER_PATH"
else
    echo "Error: logger.sh not found at $LOGGER_PATH"
    exit 1
fi

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper to run a test case and verify output
# Usage: assert_log <level_function> <message> <expected_pattern>
assert_log() {
    local func=$1
    local msg=$2
    local pattern=$3
    
    echo -n "Testing [$func] with message '$msg'... "
    
    # Capture stderr to a variable
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

# 1. Test Basic Log Levels (Human Readable)
# We check if the level name appears in the stderr output
assert_log "debug" "This is a debug message" "\[debug\]"
assert_log "info"  "This is an info message"  "\[info\]"
assert_log "warn"  "This is a warning message"  "\[warn\]"
assert_log "error" "This is an error message"    "\[error\]"

# 2. Test JSON Output
# Since log_observer_json_stderr is also subscribed, it outputs JSON.
# We verify that the JSON contains the level and the message.
echo -n "Testing JSON encoding... "
JSON_OUT=$(info "json test" 2>&1)
if echo "$JSON_OUT" | grep -q '"level": "info"' && echo "$JSON_OUT" | grep -q '"data": "json test"'; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Output: $JSON_OUT"
fi

# 3. Test Error Stack Trace
# The 'error' function should trigger the backtrace implementation.
echo -n "Testing Error Backtrace... "
ERR_OUT=$(error "critical failure" 2>&1)
if echo "$ERR_OUT" | grep -q '"stack":' && echo "$ERR_OUT" | grep -q 'backtrace'; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Error output did not contain stack trace."
fi

echo "--- Test Suite Complete ---"
