#!/bin/bash

set -euo pipefail

source /etc/os-release

if [[ "${ID}" != "debian" ]]; then
	echo "This installer is configured for Debian-based dev containers."
	exit 1
fi

MONGODB_VERSION="8.0"
REPO_CODENAME="${VERSION_CODENAME}"

if [[ "${REPO_CODENAME}" == "trixie" ]]; then
	REPO_CODENAME="bookworm"
fi

# Remove old MongoDB repo and key files that can break apt update.
sudo rm -f /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo rm -f /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo rm -f /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg
sudo rm -f /usr/share/keyrings/mongodb-server-8.0.gpg

# Install MongoDB from official Debian repository using keyring-based signing.
curl -fsSL "https://pgp.mongodb.com/server-${MONGODB_VERSION}.asc" | sudo gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${MONGODB_VERSION}.gpg"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODB_VERSION}.gpg ] https://repo.mongodb.org/apt/debian ${REPO_CODENAME}/mongodb-org/${MONGODB_VERSION} main" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION}.list

sudo apt-get update
sudo apt-get install -y mongodb-org

# Create necessary directories and set permissions
sudo mkdir -p /data/db
sudo chown -R mongodb:mongodb /data/db
