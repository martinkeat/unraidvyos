# Stage 1: Prepare VyOS
FROM debian:buster-slim as vyos-prep

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    squashfs-tools \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /vyos

# Fetch the latest release tag from GitHub
RUN LATEST_TAG=$(curl -s https://api.github.com/repos/vyos/vyos-rolling-nightly-builds/releases/latest | jq -r '.tag_name') \
    && echo "Latest release tag is $LATEST_TAG"

# Construct the download URL using the latest tag
# Replace this with the appropriate URL format for VyOS releases
RUN curl -L -o vyos.iso "https://github.com/vyos/vyos-rolling-nightly-builds/releases/download/${LATEST_TAG}/vyos-${LATEST_TAG}-amd64.iso"

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
