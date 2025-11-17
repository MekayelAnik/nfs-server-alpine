#!/bin/bash

# Define variables
DOCKERFILE_NAME="./Dockerfile.nfs-server-alpine"
STABLE_ALPINE_VERSION="latest" 
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF > "${DOCKERFILE_NAME}"
# Use Alpine Linux - Using a stable version for reliability
FROM alpine:${STABLE_ALPINE_VERSION}

# Define an ARG to hold the version
ARG NFS_VERSION="unknown"

# Set environment variables
ENV TZ="\${TZ:-Asia/Dhaka}" \\
    NFS_MOUNT_PORT=2049 \\
    NUMBER_OF_SHARES=0 \\
    READ_WRITE=rw \\
    SYNC=sync \\
    ROOT_SQUASH=no_root_squash \\
    SECURE=insecure \\
    SUBTREE_CHECK=no_subtree_check \\
    NLM=no_auth_nlm

# --- CORE OPTIMIZATION: Single layer installation ---
RUN apk update && \\
    export NFS_VERSION=\$(apk search --print-ver nfs-utils) && \\
    /bin/echo "NFS_VERSION=\${NFS_VERSION}" >> /etc/profile.d/nfs_version.sh && \\
    apk --upgrade add bash net-tools nfs-utils tzdata libcap && \\
    rm -rf /var/cache/apk/* /tmp/* && \\
    rm -vf /etc/idmapd.conf /etc/exports && \\
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \\
    mkdir /export && chmod a+rwxt /export && \\
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \\
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

# Use the dynamically captured version in the final LABEL
LABEL org.opencontainers.image.created="${BUILD_DATE}" \\
    org.opencontainers.image.version="\${NFS_VERSION}" \\
    org.opencontainers.image.authors="MUHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>" \\
    org.opencontainers.image.source="https://github.com/MekayelAnik/nfs-server-alpine" \\
    org.opencontainers.image.licenses="GPL-3.0"

# Add local resources AFTER package installation to prevent cache invalidation
ADD --chmod=555 ./resources /usr/bin

# Expose NFS ports
EXPOSE 2049 111/udp 111/tcp 2049/udp 2049/tcp

# Define service entrypoint
ENTRYPOINT ["/usr/bin/nfsd.sh"]
EOF

echo "Successfully generated the final, optimized Dockerfile content in ${DOCKERFILE_NAME}"
echo "Note: The Dockerfile is configured to capture the NFS version (\$(apk search --print-ver nfs-utils)) during the build."