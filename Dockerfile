# Base Image
FROM ubuntu:20.04

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and utilities
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
    postgresql \
    sudo \
    && apt-get clean

# Install Node.js 20 (Use NodeSource to get the latest stable version)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && npm install -g next

# Install code-server from the official repository
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install PostgreSQL and set up devuser with privileges
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER devuser WITH PASSWORD 'devpassword';" && \
    sudo -u postgres psql -c "ALTER USER devuser WITH SUPERUSER;" && \
    sudo -u postgres psql -c "CREATE DATABASE devdb;" && \
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE devdb TO devuser;"

# Create a development user (replace 'devpassword' with a securely generated password)
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:devpassword" | chpasswd && \
    adduser devuser sudo

# Set up the home directory for devuser
WORKDIR /home/devuser

# Install VS Code extensions
RUN echo "#!/bin/bash\n \
    code-server --install-extension esbenp.prettier-vscode --force && \
    code-server --install-extension dbaeumer.vscode-eslint --force && \
    code-server --install-extension ms-vscode.vscode-typescript-tslint-plugin --force && \
    code-server --install-extension msjsdiag.debugger-for-chrome --force && \
    code-server --install-extension njpwerner.autodocstring --force && \
    code-server --install-extension AmazonWebServices.aws-toolkit-vscode --force && \
    code-server --install-extension redhat.vscode-yaml --force && \
    code-server --install-extension eamodio.gitlens --force && \
    code-server --install-extension ms-vscode.go --force && \
    code-server --install-extension ms-vscode.node-debug2 --force && \
    code-server --install-extension formulahendry.code-runner --force" > /home/devuser/install-extensions.sh

RUN chmod +x /home/devuser/install-extensions.sh

# Set entrypoint for code-server and PostgreSQL (ensure the correct password is passed during container start)
ENTRYPOINT ["/bin/bash", "-c", "/home/devuser/install-extensions.sh && code-server --bind-addr 0.0.0.0:8080 --auth password"]

# Expose the port for VS Code server
EXPOSE 8080

# Set the working directory to the devuser home
USER devuser
WORKDIR /home/devuser

# Default command to start the application
CMD ["bash"]
