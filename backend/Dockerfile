# Use the official Rust image as the base image
FROM rust:1.81

RUN useradd -m rustuser

RUN apt-get update && apt-get install -y cron

# Add crontab file
COPY crontab.txt /etc/cron.d/reallystick-cron
RUN chmod 0644 /etc/cron.d/reallystick-cron
RUN crontab -u rustuser /etc/cron.d/reallystick-cron
RUN touch /var/log/cron.log
RUN chown rustuser:rustuser /var/log/cron.log
RUN chmod u+s /usr/sbin/cron

USER rustuser

# Install cargo-watch
RUN cargo install cargo-watch

# Set the working directory inside the container
WORKDIR /app

# Now copy the rest of the source code
COPY --chown=rustuser:rustuser . .
