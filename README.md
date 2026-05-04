# 🚀 Bash Event-Driven Logger

[![Bash Shell](https://img.shields.io/badge/Shell-Bash-4EAA7B?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![JSON](https://img.shields.io/badge/Format-JSON-white?logo=json&logoColor=black)](https://www.json.org/)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)](https://github.com/glaudiston/event-driven)

A high-performance, decoupled logging framework for Bash scripts. Unlike traditional loggers, this implementation uses a **Pub-Sub 
(Publisher-Subscriber) pattern**, allowing you to attach multiple "observers" to your logs without changing your business logic.

---

## 🌟 The Core Concept

Most Bash scripts use `echo` or simple functions. **Bash Event-Driven Logger** treats every log entry as an **Event**.

**The Flow:**
`Log Function` $\rightarrow$ `Event Bus` $\rightarrow$ `Observers (JSON, Console, File, etc.)`

This means you can simultaneously:
1. 🎨 Print **color-coded** logs to the terminal for humans.
2. 📦 Stream **JSON-encoded** logs to `stderr` for log aggregators (ELK, Datadog).
3. 🔍 Automatically capture **stack-traces** only when an `error` occurs.

---

## ✨ Key Features

- **Decoupled Architecture**: Add or remove logging destinations (observers) at runtime via `subscribe`.
- **Automatic Backtracing**: Integrated with `backtrace.sh` to automatically dump the call stack on `error` levels.
- **Machine-Ready**: Built-in `jq` integration for valid JSON output.
- **TUI Ready**: Uses `termsdk` for professional ANSI terminal coloring.
- **Low Overhead**: Powered by `pragma_once` to prevent redundant import overhead.

---

## 🛠 Installation & Setup

Since this logger depends on several specialized Bash libraries, it uses **Git Submodules**. Follow these steps to get it running:

### 1. Clone the Repository
To clone the project along with all its dependencies in one command, use:
```bash
git clone --recursive https://github.com/glaudiston/logger.git
cd logger
```

**Already cloned the repo without `--recursive`?**  
Run these commands to fetch the missing dependencies:
```bash
git submodule update --init --recursive
```

### 2. Install System Dependencies
The logger requires `jq` for JSON processing.
- **Ubuntu/Debian:** `sudo apt-get install jq`
- **macOS:** `brew install jq`
- **CentOS/RHEL:** `sudo yum install jq`

### 3. Requirements
- **Bash:** version 4.0+
- **jq:** installed and available in your PATH

---

## 🚀 Quick Start

### Basic Usage
Include the logger in your script and start logging:

```bash
#!/bin/bash
. ./logger.sh

debug "This is a hidden developer detail"
info  "System is starting up..."
warn  "Disk space is reaching 80%"
error "Could not connect to Database!" # This will automatically trigger a stack-trace!
```

### What happens under the hood?

| Level | Terminal Output (Human) | JSON Output (Machine) | Feature |
| :--- | :--- | :--- | :--- |
| `debug` | `[DEBUG] message` | `{"level":"debug", ...}` | Standard |
| `info` | `[INFO] message` | `{"level":"info", ...}` | Standard |
| `warn` | `[WARN] message` | `{"level":"warn", ...}` | Standard |
| `error`| `[ERROR] message` $\rightarrow$ **Stacktrace** | `{"level":"error", "stack": [...]}` | **Auto-Backtrace** |

---

## 🔧 Advanced: Adding Custom Observers

Because the logger is event-driven, you can create your own observer to send logs to a file or a remote API without touching the 
`logger.sh` core.

```bash
# Define a custom observer
log_to_file() {
    shift 3 # ignore topic, hash, timestamp
    echo "[$(date)] $1" >> /var/log/my_app.log
}

# Subscribe to the LOG topic
subscribe LOG log_to_file

# Now, every info/warn/error call will also write to the file!
info "This now goes to terminal AND the file"
```

---

## 🧪 Test Suite

The project includes a robust test suite to ensure routing and formatting are correct.

```bash
bash logger_test.sh
```

**Test Coverage:**
- [x] Log Level Routing (Debug $\rightarrow$ Error)
- [x] JSON Schema Validation
- [x] Backtrace Triggering on Error
- [x] Stderr Redirection

---

## 📜 License

MIT License. Feel free to use and contribute!
