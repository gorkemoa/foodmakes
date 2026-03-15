#!/usr/bin/env zsh
# Start LibreTranslate on port 5050 (5000 is reserved by macOS AirPlay Receiver)

SCRIPT_DIR="${0:A:h}"
VENV="$SCRIPT_DIR/libre_env"

# Kill any previous instance on this port
kill $(lsof -ti :5050) 2>/dev/null

source "$VENV/bin/activate"
export SSL_CERT_FILE=$(python3 -c "import certifi; print(certifi.where())")

echo "Starting LibreTranslate on http://127.0.0.1:5050 ..."
libretranslate --port 5050 --load-only en,tr,es
