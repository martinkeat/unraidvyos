# Stage 1: Prepare VyOS
FROM debian:buster-slim as vyos-prep

# Set environment variables to avoid interactive dialogues during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    squashfs-tools \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /vyos

# Download the latest VyOS ISO
# Replace this URL with the command to dynamically fetch the latest release
RUN curl -L -o vyos.iso 'https://downloads.vyos.io/?dir=rolling/current/amd64'

# Create directories for unsquashing the ISO
RUN mkdir /vyos/unsquashfs

# Unsquash the filesystem
# Note: This step assumes the ISO can be unsquashed directly without mounting
RUN unsquashfs -f -d /vyos/unsquashfs/ vyos.iso

# Stage 2: Build the final image
FROM debian:buster-slim

# Copy the prepared filesystem from the previous stage
COPY --from=vyos-prep /vyos/unsquashfs/ /

# Set the entrypoint
ENTRYPOINT ["/sbin/init"]

# Expose necessary ports
EXPOSE 22 443
