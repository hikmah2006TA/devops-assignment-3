#!/usr/bin/env bash

set -u

show_help() {
    cat <<'HELP'
DevOps Diagnostic Tool

Usage:
  ./app/app.sh system-info
  ./app/app.sh check-host <host>
  ./app/app.sh check-port <host> <port>
  ./app/app.sh help

Commands:
  system-info          Display Linux system information.
  check-host <host>    Resolve a hostname or IP address.
  check-port <host> <port>
                       Check TCP connectivity to a port.
  help                 Display this help message.

Exit codes:
  0  Success
  1  Operational failure
  2  Invalid command or input
HELP
}

system_info() {
    echo "===== System Information ====="
    echo "Hostname: $(hostname)"
    echo "Operating System: $(uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Current User: $(id -un)"
    echo "Current Directory: $PWD"

    if [[ -r /proc/meminfo ]]; then
        awk '/^MemTotal:/ {printf "Total Memory: %.2f GB\n", $2/1048576}' /proc/meminfo
    fi

    return 0
}

check_host() {
    local host="$1"

    if ! getent ahosts "$host" >/dev/null 2>&1; then
        echo "Error: Unable to resolve host '$host'." >&2
        return 1
    fi

    echo "Host '$host' resolved successfully."
    getent ahosts "$host" | awk 'NR == 1 {print "Address: " $1}'
    return 0
}

check_port() {
    local host="$1"
    local port="$2"

    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number." >&2
        return 2
    fi

    if (( 10#$port < 1 || 10#$port > 65535 )); then
        echo "Error: Port must be between 1 and 65535." >&2
        return 2
    fi

    if ! getent ahosts "$host" >/dev/null 2>&1; then
        echo "Error: Unable to resolve host '$host'." >&2
        return 1
    fi

    if timeout 3 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$host" "$port" 2>/dev/null; then
        echo "TCP connection to $host:$port succeeded."
        return 0
    else
        echo "Error: TCP connection to $host:$port failed." >&2
        return 1
    fi
}

if [[ $# -eq 0 ]]; then
    echo "Error: A command is required." >&2
    show_help >&2
    exit 2
fi

command_name="$1"
shift

case "$command_name" in
    help)
        if [[ $# -ne 0 ]]; then
            echo "Error: help does not accept arguments." >&2
            exit 2
        fi
        show_help
        ;;

    system-info)
        if [[ $# -ne 0 ]]; then
            echo "Error: system-info does not accept arguments." >&2
            exit 2
        fi
        system_info
        ;;

    check-host)
        if [[ $# -ne 1 || -z "$1" ]]; then
            echo "Error: check-host requires exactly one host." >&2
            exit 2
        fi
        check_host "$1"
        exit $?
        ;;

    check-port)
        if [[ $# -ne 2 || -z "$1" || -z "$2" ]]; then
            echo "Error: check-port requires a host and a port." >&2
            exit 2
        fi
        check_port "$1" "$2"
        exit $?
        ;;

    *)
        echo "Error: Invalid command '$command_name'." >&2
        show_help >&2
        exit 2
        ;;
esac
