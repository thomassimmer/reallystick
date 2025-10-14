#!/bin/sh

# Start your application in the foreground
exec cargo run --release --bin notifications
