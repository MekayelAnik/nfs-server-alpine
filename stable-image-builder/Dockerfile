ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka
ENV NFS_MOUNT_PORT=2049 \
    NUMBER_OF_SHARES=0 \
    READ_WRITE=rw \
    SYNC=sync \
    ROOT_SQUASH=no_root_squash \
    SECURE=insecure \
    SUBTREE_CHECK=no_subtree_check \
    NLM=no_auth_nlm
COPY --chmod=444 ./build-timestamp /usr/bin
COPY --chmod=555 ./nfsd.sh /usr/local/bin
COPY --chmod=555 ./banner.sh /usr/local/bin
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade  && \
    apk --update --no-cache add bash net-tools nfs-utils tzdata libcap && \
    rm -rf /var/cache/apk/*  && \
    rm -v /etc/idmapd.conf /etc/exports && \
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    mkdir /export && chmod a+rwxt /export && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

ENTRYPOINT ["/usr/local/bin/nfsd.sh"]
