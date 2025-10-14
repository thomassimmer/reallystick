#!/bin/sh

# Start your application in the foreground
exec cargo watch -q -c -x "run --bin notifications"
