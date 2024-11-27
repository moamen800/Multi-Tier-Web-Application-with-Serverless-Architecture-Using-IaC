#!/bin/sh

# Replace 'localhost' with the value of $ALBDNS in all files
if [ -z "$ALBDNS" ]; then
  echo "Environment variable ALBDNS is not set. Exiting."
  exit 1
fi

find /usr/share/nginx/html -type f -exec sed -i "s/localhost/$ALBDNS/g" {} +

# Start Nginx
exec "$@"
