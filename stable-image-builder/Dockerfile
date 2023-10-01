# Use Alpine Linux
ARG ALPINE_VERSION=edge
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka

LABEL author="MUHAMMAD MEKAYEL ANIK"
LABEL author_email="mekayel.anik@gmail.com"
LABEL github_url="https://github.com/MekayelAnik/samba-server-alpine"
LABEL licence="GPL-3.0"

ENV NFS_MOUNT_PORT=2049 \
    NUMBER_OF_SHARES=0 \
    READ_WRITE=rw \
    SYNC=sync \
    ROOT_SQUASH=no_root_squash \
    SECURE=insecure \
    SUBTREE_CHECK=no_subtree_check \
    NLM=no_auth_nlm

ADD --chmod=555 ./scripts  /usr/bin

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

ENTRYPOINT ["/usr/bin/nfsd.sh"]
