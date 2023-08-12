ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka
RUN date +%c > /build-timestamp
ENV NFS_MOUNT_PORT=2049 \
    NFS_ROOT_DIR=/nfs-shares \
    NUMBER_OF_SHARES=0 \
    READ_WRITE=rw \
    SYNC=sync \
    ROOT_SQUASH=no_root_squash \
    SECURE=insecure \
    SUBTREE_CHECK=no_subtree_check \
    NLM=no_auth_nlm

RUN apk --update --no-cache add bash nfs-utils tzdata libcap && \
    # remove the default config files
    rm -v /etc/idmapd.conf /etc/exports && \
    # http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    mkdir /export && chmod a+rwxt /export && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab
RUN apk --update --no-cache upgrade && \
    rm -f /bin/netstat && \
    rm -rf /var/cache/apk/*

# setup entrypoint
COPY --chmod=555 ./nfsd.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/nfsd.sh"]
