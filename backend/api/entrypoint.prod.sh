#!/bin/sh

# Start cron in the background
cron

# Start your application in the foreground
exec cargo run --release --bin api
