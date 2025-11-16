#!/bin/sh

# Start cron in the background
cron

# Start the compiled application binary in the foreground
exec /usr/local/bin/api
