#!/bin/sh

# Start your application in the foreground
exec cargo watch -q -c -w src/ -x "run --bin notifications"
