#!/bin/sh

set -e

echo "Downloading Amazon DocumentDB Certificate Authority (CA) certificate..."
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || { echo "Failed to download DocumentDB CA certificate"; exit 1; }

# Ensure MongoDB URI is provided
if [ -z "$MONGO_URI" ]; then
  echo "Error: MONGO_URI is not set."
  exit 1
fi

echo "Starting application with MongoDB URI: $MONGO_URI"

# Pass control to CMD (specified in the Dockerfile)
exec "$@"
