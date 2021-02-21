#!/usr/bin/env bash

port_file=$(mktemp)
proxy_pid_file=$(mktemp)

echo '0' > "$port_file"
echo '0' > "$proxy_pid_file"
BUFFER_SIZE=${BUFFER_SIZE:-65535}

while true; do (
    new_port=$(curl "$PORT_VALUE_URL" 2>/dev/null)
    port=$(cat "$port_file")
    if [[ "$new_port" != "$port" ]]; then
        echo "Port changed from $port to $new_port"
        echo "$new_port" > "$port_file"

        proxy_pid=$(cat "$proxy_pid_file")
        if [[ $proxy_pid -ne 0 ]]; then
            kill "$proxy_pid"
        fi

        echo "relay TCP/IP connections on :${LISTEN_PORT} to ${HOST}:${new_port}"
        socat -b"$BUFFER_SIZE" TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr TCP:${HOST}:${new_port} &
        echo "$!" > "$proxy_pid_file"

        echo "Using new port $new_port"
    fi
    sleep "$SLEEP_TIME"
); done
