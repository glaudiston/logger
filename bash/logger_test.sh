#!/usr/bin/env bash

# --- Setup ---
LOGGER_PATH="$(dirname "$(realpath "$BASH_SOURCE")")/logger.sh"
if [[ -f "$LOGGER_PATH" ]]; then
    . "$LOGGER_PATH"
else
    echo "❌ Error: logger.sh not found at $LOGGER_PATH"
    exit 1
fi

# --- UI Colors & Symbols ---
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECK_MARK="✅"
CROSS_MARK="❌"
INFO_MARK="ℹ️"

# Test Counters
TOTAL=0
PASSED=0
FAILED=0

# --- Helper Functions ---

print_banner() {
    echo -e "\n${BOLD}${CYAN}====================================================${NC}"
    echo -e "${BOLD}${CYAN}   📜 LOGGER EVENT-DRIVEN TEST SUITE               ${NC}"
    echo -e "${BOLD}${CYAN}====================================================${NC}"
}

# Generic assertion function
# Args: $1=Test Name, $2=Command to execute, $3=Expected Pattern
assert_pattern() {
    local test_name="$1"
    local cmd="$2"
    local pattern="$3"
    set +e
    ((TOTAL++))
    
    # Capture both stdout and stderr
    local output
    output=$(eval "$cmd" 2>&1)
    
    if echo "$output" | grep -q "$pattern"; then
        printf "${GREEN}${CHECK_MARK}${NC} ${BOLD}%-30s${NC} [${GREEN}PASS${NC}]\n" "$test_name"
        ((PASSED++))
    else
        printf "${RED}${CROSS_MARK}${NC} ${BOLD}%-30s${NC} [${RED}FAIL${NC}]\n" "$test_name"
        echo -e "    ${YELLOW}Expected pattern:${NC} $pattern"
        echo -e "    ${YELLOW}Actual output:${NC}    $output"
        ((FAILED++))
    fi
}

print_summary() {
    echo -e "\n${BOLD}${CYAN}====================================================${NC}"
    echo -e "  ${BOLD}Test Summary:${NC}"
    echo -e "  Total:  $TOTAL"
    echo -e "  Passed:  ${GREEN}$PASSED${NC}"
    echo -e "  Failed:  ${RED}$FAILED${NC}"
    echo -e "${BOLD}${CYAN}====================================================${NC}\n"
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 ALL TESTS PASSED!${NC}\n"
        exit 0
    else
        echo -e "${RED}${BOLD}🚨 SOME TESTS FAILED!${NC}\n"
        exit 1
    fi
}

# --- Execution ---

print_banner

echo -e "\n${BOLD}1. Basic Log Level Routing${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
assert_pattern "Debug Level"  'debug "test debug"'  "[DEBUG]"
assert_pattern "Info Level"     'info  "test info"'   "[INFO]"
assert_pattern "Warn Level"     'warn  "test warn"'    "[WARN]"
assert_pattern "Error Level"    'error "test error"'  "[ERROR]"

echo -e "\n${BOLD}2. JSON Output Validation${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
# Testing if the JSON observer correctly encodes the payload
assert_pattern "JSON Level Field"   'info "json test"'   '"level":"info"'
assert_pattern "JSON Data Field"    'info "json test"'    '"data":"json test"'

echo -e "\n${BOLD}3. Error & Backtrace Validation${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
# Error should trigger both the human-readable backtrace and the JSON stack-trace
assert_pattern "JSON Stacktrace"    'error "critical"'    '"stack":'
assert_pattern "Stderr Backtrace"  'error "critical"'   'backtrace'

print_summary
