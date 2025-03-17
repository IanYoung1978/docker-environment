# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    sudo \
    ca-certificates \
    git \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    postgresql \
    && apt-get clean

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Create a non-root user
RUN useradd -ms /bin/bash devuser && \
    echo 'devuser:devpassword' | chpasswd && \
    adduser devuser sudo

# Set working directory to devuser's home
WORKDIR /home/devuser

# Create a config directory for code-server
RUN mkdir -p /home/devuser/.config/code-server

# Generate a password (or manually set it if desired)
RUN echo "bind-addr: 0.0.0.0:8080\n\
auth: password\n\
password: devpassword\n\
cert: false" > /home/devuser/.config/code-server/config.yaml

# Write the script to install VS Code extensions
RUN echo '#!/bin/bash\n\
code-server --install-extension ms-python.python --force\n\
code-server --install-extension ms-python.vscode-pylance --force\n\
code-server --install-extension ms-azuretools.vscode-docker --force\n\
code-server --install-extension esbenp.prettier-vscode --force\n\
code-server --install-extension dbaeumer.vscode-eslint --force\n\
code-server --install-extension ms-vscode.vscode-typescript-tslint-plugin --force\n\
code-server --install-extension msjsdiag.debugger-for-chrome --force\n\
code-server --install-extension njpwerner.autodocstring --force\n\
code-server --install-extension ms-vscode.aws-toolkit-vscode --force\n\
code-server --install-extension redhat.vscode-yaml --force\n\
code-server --install-extension eamodio.gitlens --force\n\
code-server --install-extension ms-vscode.go --force\n\
code-server --install-extension ms-vscode.node-debug2 --force\n\
code-server --install-extension formulahendry.code-runner --force\n' > /home/devuser/install-extensions.sh

# Set executable permissions for the script
RUN chmod +x /home/devuser/install-extensions.sh

# Switch to non-root user
USER devuser

# Run the extension installation script
RUN /home/devuser/install-extensions.sh

# Expose port for code-server
EXPOSE 8080

# Start code-server on container startup
CMD ["code-server"]
