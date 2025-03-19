#!/bin/bash

# Set password securely (pass it via Docker secrets or environment variables)
if [ -z "$CODE_SERVER_PASSWORD" ]; then
    echo "ERROR: CODE_SERVER_PASSWORD is not set. Exiting..."
    exit 1
fi

# Start PostgreSQL service
sudo service postgresql start

# Run the VS Code extensions installation script
bash /home/devuser/install-extensions.sh

# Start code-server
exec code-server --host 0.0.0.0 --port 8080 --auth password
