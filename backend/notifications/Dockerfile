# Use the official Rust image as the base image
FROM rust:1.90

RUN useradd -m rustuser

USER rustuser

# Install cargo-watch
RUN cargo install cargo-watch

# Set the working directory inside the container
WORKDIR /app/notifications

# Now copy the rest of the source code
COPY --chown=rustuser:rustuser . .
