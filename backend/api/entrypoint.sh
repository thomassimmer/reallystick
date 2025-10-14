#!/bin/sh

# Start cron in the background
cron

# Start your application in the foreground
exec cargo watch -q -c -x "run --bin api"
