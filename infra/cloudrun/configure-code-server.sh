#!/bin/bash
set -e

HTTP_PORT="${HTTP_PORT:-8080}"

# If PASSWORD is empty, fall back to no-auth (Cloudflare Access only)
AUTH_MODE="none"
if [ -n "${PASSWORD}" ]; then
  AUTH_MODE="password"
fi

cat > /home/coder/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:${HTTP_PORT}
auth: ${AUTH_MODE}
password: ${PASSWORD}
cert: false
EOF

chown -R coder:coder /home/coder/.config

echo "Starting code-server on port ${HTTP_PORT} with auth mode: ${AUTH_MODE}"
exec code-server --config /home/coder/.config/code-server/config.yaml
