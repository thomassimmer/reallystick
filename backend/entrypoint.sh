#!/bin/sh

# Start cron in the background
cron

# Start your application in the foreground
exec cargo watch -q -c -w src/ -x "run --bin reallystick"
