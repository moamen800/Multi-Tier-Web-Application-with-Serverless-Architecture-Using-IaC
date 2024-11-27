#!/bin/sh

set -e

# Ensure MongoDB URI is provided
if [ -z "$MONGO_URI" ]; then
  echo "Error: MONGO_URI is not set."
  exit 1
fi

echo "Starting application with MongoDB URI: $MONGO_URI"

# Pass control to CMD (if specified)
exec "$@"
