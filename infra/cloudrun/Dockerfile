# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CODE_SERVER_USER=coder
ENV HTTP_PORT=8080

# GitHub OAuth (optional - provide these in Terraform)
ENV GITHUB_CLIENT_ID="Ov23li0eKopVqwBJQHZq"
ENV GITHUB_CLIENT_SECRET="62e3db27fbb170aabe1bfdab5727813a849abbc5"
ENV GITHUB_REDIRECT_URI="https://vscode-server-cloudrun-6xhznsmgzq-ez.a.run.app/login/github/callback"

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y curl gnupg2 software-properties-common sudo debian-keyring debian-archive-keyring apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Create dedicated user
RUN useradd -m -s /bin/bash ${CODE_SERVER_USER} && \
    usermod -aG sudo ${CODE_SERVER_USER} && \
    mkdir -p /home/${CODE_SERVER_USER}/.cache /home/${CODE_SERVER_USER}/.local/share/code-server/extensions && \
    chown -R ${CODE_SERVER_USER}:${CODE_SERVER_USER} /home/${CODE_SERVER_USER} && \
    chmod -R 700 /home/${CODE_SERVER_USER} && \
    echo "${CODE_SERVER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install code-server
RUN export HOME="/root" && \
    curl -fsSL https://code-server.dev/install.sh | sh

# Configure code-server
RUN mkdir -p /home/${CODE_SERVER_USER}/.config/code-server

# Create config generation script
RUN echo '#!/bin/bash' > /usr/local/bin/configure-code-server.sh && \
    echo 'echo "bind-addr: 0.0.0.0:${HTTP_PORT}" > /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo 'echo "cert: false" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo 'if [ -n "$GITHUB_CLIENT_ID" ] && [ -n "$GITHUB_CLIENT_SECRET" ]; then' >> /usr/local/bin/configure-code-server.sh && \
    echo '  echo "auth: github" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo '  echo "github.client-id: $GITHUB_CLIENT_ID" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo '  echo "github.client-secret: $GITHUB_CLIENT_SECRET" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo '  [ -n "$GITHUB_REDIRECT_URI" ] && echo "github.redirect-uri: $GITHUB_REDIRECT_URI" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo 'else' >> /usr/local/bin/configure-code-server.sh && \
    echo '  echo "auth: password" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo '  echo "password: ${PASSWORD:-P@ssw0rd@123}" >> /home/${CODE_SERVER_USER}/.config/code-server/config.yaml' >> /usr/local/bin/configure-code-server.sh && \
    echo 'fi' >> /usr/local/bin/configure-code-server.sh && \
    echo 'chown -R ${CODE_SERVER_USER}:${CODE_SERVER_USER} /home/${CODE_SERVER_USER}/.config' >> /usr/local/bin/configure-code-server.sh && \
    chmod +x /usr/local/bin/configure-code-server.sh

# Switch to non-root user
USER ${CODE_SERVER_USER}

# Expose port
EXPOSE ${HTTP_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${HTTP_PORT}/healthz || exit 1

# Create entrypoint script
RUN echo '#!/bin/bash' > /usr/local/bin/entrypoint.sh && \
    echo '/usr/local/bin/configure-code-server.sh' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec code-server --config /home/coder/.config/code-server/config.yaml' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Start code-server with dynamic configuration
CMD ["/usr/local/bin/entrypoint.sh"]