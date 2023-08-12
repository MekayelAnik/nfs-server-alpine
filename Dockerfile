ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka

RUN apk --update --no-cache add bash nfs-utils tzdata libcap && \
    # remove the default config files
    rm -v /etc/idmapd.conf /etc/exports && \
    # http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    mkdir /export && chmod a+rwxt /export && \
    mkdir /nfs-shares && chmod 700 /nfs-share && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

EXPOSE 2049

# setup entrypoint
COPY --chmod=555 ./entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
