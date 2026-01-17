#!/bin/bash

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

LOG_FILE=$(mktemp)

echo "🛑 Stopping innovacad service to free binary file..."
sudo systemctl stop innovacad

echo -n "🔨 Building Innovacad API (Dart)..."
cd innovacad_api || exit

dart compile exe bin/server.dart -o server > "$LOG_FILE" 2>&1 &
PID=$!

spinner $PID

wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Done!"
    echo "🚀 Starting innovacad service..."
    sudo systemctl start innovacad
else
    echo "❌ Failed while building dart."
    echo "--- ERROR LOG ---"
    cat "$LOG_FILE"
    echo "-------------------"
    rm "$LOG_FILE"
    exit 1
fi

cd ..

echo "------------------------------------------------"
echo -n "🔨 Building Innovacad Auth API (Bun)..."
cd innovacad_auth_api || exit

bun run build > "$LOG_FILE" 2>&1 &
PID=$!

spinner $PID

wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ DONE!"
    echo "🚀 Restarting innovacad-auth service..."
    sudo systemctl restart innovacad-auth
else
    echo "❌ Failed while building elysia...."
    echo "--- ERROR LOG ---"
    cat "$LOG_FILE"
    echo "-------------------"
    rm "$LOG_FILE"
    exit 1
fi

rm "$LOG_FILE"

echo "------------------------------------------------"
echo "✅ Deployment Completed!"


systemctl status innovacad
wait
systemctl status innovacad-auth
