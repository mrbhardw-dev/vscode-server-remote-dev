# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CODE_SERVER_USER=coder
ENV HTTP_PORT=8080

# GitHub OAuth (optional - provide these as environment variables)

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

# Copy configuration script
COPY configure-code-server.sh /usr/local/bin/configure-code-server.sh
RUN chmod +x /usr/local/bin/configure-code-server.sh

# Switch to non-root user
USER ${CODE_SERVER_USER}

# Expose port
EXPOSE ${HTTP_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${HTTP_PORT}/healthz || exit 1

# Start code-server with dynamic configuration
CMD ["/usr/local/bin/configure-code-server.sh"]