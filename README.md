<h1>NFS Server multi-arch image</h1>
<p>A Multi-Aarch image for lightweight, highly customizable, containerized NFS server</p>
<img alt="NFS" src="https://linux-nfs.org/wiki/logo.png">
<p>This is an unofficial Multi-Aarch docker image of NFS Server created for multiplatform support. This image creates a local NFS Server to facilitate client-side data transfer. Official Website: <a href="https://wiki.linux-nfs.org" rel="nofollow noopener">https://wiki.linux-nfs.org</a>
</p>
<h2>The architectures supported by this image are:</h2>
<table>
  <thead>
    <tr>
      <th align="center">Architecture</th>
      <th align="center">Available</th>
      <th>Tag</th>
       <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">x86-64</td>
      <td align="center">✅</td>
      <td>amd64-&lt;version tag&gt;</td>
      <td>Tested "WORKING"</td>
    </tr>
    <tr>
      <td align="center">arm64</td>
      <td align="center">✅</td>
      <td>arm64v8-&lt;version tag&gt;</td>
      <td>Tested "WORKING"</td>
    </tr>
    <tr>
      <td align="center">armhf</td>
      <td align="center">✅</td>
      <td>arm32v7-&lt;version tag&gt;</td>
      <td>Tested "WORKING"</td>
    </tr>
  </tbody>
</table>
<h2>Version Tags</h2>
<table>
  <thead>
    <tr>
      <th align="center">Tag</th>
      <th align="center">Available</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">latest</td>
      <td align="center">✅</td>
      <td>Stable "NFS releases</td>
    </tr>
    <tr>
      <td align="center">4.2</td>
      <td align="center">✅</td>
      <td>Static "NFS" build version 4.2</td>
    </tr>
  </tbody>
</table>
<h2>Running Image :</h2>
<p>Here are some example snippets to help you get started creating a container.</p>
<h3>Docker Compose (recommended, <a href="https://itnext.io/a-beginners-guide-to-deploying-a-docker-application-to-production-using-docker-compose-de1feccd2893" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>---
version: "3.9"
services:
  nfs-server:
    image: mekayelanik/nfs-server-alpine:latest
    container_name: nfs-server-1
    environment:
      - TZ=Asia/Dhaka
      - ALLOWED_CLIENT=192.168.1.1/24
      - NFS_MOUNT_PORT=2049
# Number of Shares without ROOT DIR
      - NUMBER_OF_SHARES=2
      - NFS_EXPORT_1=/share1
      - NFS_EXPORT_2=/share2
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# Always Add the value of NFS_ROOT_DIR before the NFS_EXPORTs while mapping to Data Dir
      - /path/to/root-data:/data
      - /path/to/shared-data1:/data/share1
      - /path/to/shared-data2:/data/share2
    ports:
      - 2049:2049
      - 111:111
      - 32765-32767:32765-32767
# Don't touch the FOLLOWING Section. This is REQUIRED to run NFS as a container (cap_add).
    cap_add:
      - SYS_ADMIN
      - SETPCAP
      - ALL
    restart: unless-stopped
</code></pre>
<h3>docker cli ( <a href="https://docs.docker.com/engine/reference/commandline/cli/" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>docker run -d \
  --name=nfs-server-alpine \
  -e TZ=Asia/Dhaka \
  -e NFS_MOUNT_PORT=2049 \
  -e NUMBER_OF_SHARES=2 \
  -e NFS_EXPORT_1=share1 \
  -e NFS_EXPORT_2=share2 \
  -e TZ=Asia/Dhaka \
  -e ALLOWED_CLIENT=192.168.1.1/24 \
  -v /path/to/root-data:/data \
  -v /path/to/shared-data1:/data/share1 \
  -v /path/to/shared-data2:/data/share2 \
  --restart unless-stopped \
  mekayelanik/nfs-server-alpine:latest
</code></pre>

<h3>If anyone wishes to give dedicated Local IP to NFS server container using MACVLAN ( <a href="https://docs.docker.com/network/macvlan/" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>---
version: "3.9"
services:
  nfs-server:
    image: mekayelanik/nfs-server-alpine:latest
    container_name: nfs-server-1
    environment:
      - TZ=Asia/Dhaka
      - ALLOWED_CLIENT=192.168.1.1/24
      - NFS_MOUNT_PORT=2049
# Number of Shares without ROOT DIR
      - NUMBER_OF_SHARES=2
      - NFS_EXPORT_1=share1
      - NFS_EXPORT_2=share2
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# Always Add the value of NFS_ROOT_DIR before the NFS_EXPORTs while mapping to Data Dir
      - /path/to/root-data:/data
      - /path/to/shared-data1:/data/share1
      - /path/to/shared-data2:/data/share2
    ports:
      - 2049:2049
      - 111:111
      - 32765-32767:32765-32767
# Don't touch the FOLLOWING Section. This is REQUIRED to run NFS as a container (cap_add).
    cap_add:
      - SYS_ADMIN
      - SETPCAP
      - ALL
    restart: unless-stopped
        hostname: nfs-server-1
    domainname: local
    mac_address: 14-24-34-44-54-64
    networks:
      macvlan-1:
        ipv4_address: 192.168.1.21
#### Network Defination ####
networks:
  macvlan-1:
    name: macvlan-1
    external: True
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: "192.168.1.0/24"
          ip_range: "192.168.1.2/24"
          gateway: "192.168.1.1"
</code></pre>

<h2>In order to mount NFS share run the Following on Client Machine</h2>
<pre><code># To mount ROOT_DIR
sudo mount -v -o vers=4.2,loud HOST-IP:/ /mount/path/to/ROOT-MOUNT-DIR
Example: sudo mount -v -o vers=4.2,loud 192.168.1.2:/ /mount/path/to/ROOT-MOUNT-DIR
# To mount NFS_EXPORTS
sudo mount -v -o vers=4.2,loud HOST-IP:/data/share1 /mount/path/to/share1
sudo mount -v -o vers=4.2,loud HOST-IP:/data/share2 /mount/path/to/share2
Example:  sudo mount -v -o vers=4.2,loud 192.168.1.2:/data/share1 /mount/path/to/share1
</code></pre>
<h2> To Un-mount</h2>
<pre><code>sudo umount /mount/path/to/share1
</code></pre>
<h2>Updating Info</h2>
<p>Below are the instructions for updating containers:</p>
<h3>Via Docker Compose (recommended)</h3>
<ul>
  <li>Update all images: <code>docker compose pull</code>
    <ul>
      <li>or update a single image: <code>docker compose pull mekayelanik/nfs-server-alpine</code>
      </li>
    </ul>
  </li>
  <li>Let compose update all containers as necessary: <code>docker compose up -d</code>
    <ul>
      <li>or update a single container (recommended): <code>docker compose up -d nfs-server-alpine</code>
      </li>
    </ul>
  </li>
  <li>To remove the old unused images run: <code>docker image prune</code>
  </li>
</ul>
<h3>Via Docker Run</h3>
<ul>
  <li>Update the image: <code>docker pull mekayelanik/nfs-server-alpine:latest</code>
  </li>
  <li>Stop the running container: <code>docker stop nfs-server-alpine</code>
  </li>
  <li>Delete the container: <code>docker rm nfs-server-alpine</code>
  </li>

  <li>To remove the old unused images run: <code>docker image prune</code>
  </li>
</ul>
<h3>Via <a href="https://containrrr.dev/watchtower/" rel="nofollow noopener">Watchtower</a> auto-updater (only use if you don't remember the original parameters)</h3>
<ul>
  <li>
    <p>Pull the latest image at its tag and replace it with the same env variables in one run:</p>
    <pre>
<code>docker run --rm \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower\
--run-once nfs-server-alpine</code></pre>
  </li>
  <li>
    <p>To remove the old unused images run: <code>docker image prune</code>
    </p>
  </li>
</ul>
<p>
  <strong>Note:</strong> You can use <a href="https://containrrr.dev/watchtower/" rel="nofollow noopener">Watchtower</a> as a solution to automated updates of existing Docker containers. But it is discouraged to use automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, it is recommend to use <a href="https://itnext.io/a-beginners-guide-to-deploying-a-docker-application-to-production-using-docker-compose-de1feccd2893" rel="nofollow noopener">Docker Compose</a>.
</p>
<h3>Image Update Notifications - Diun (Docker Image Update Notifier)</h3>
<ul>
  <li>You can also use <a href="https://crazymax.dev/diun/" rel="nofollow noopener">Diun</a> for update notifications. Other tools that automatically update containers unattended are not encouraged </li>
</ul>
<h2>Issues & Requests</h2>
<p> To submit this Docker image specific issues or requests visit this docker image's Github Link: <a href="https://github.com/MekayelAnik/nfs-server-alpine" rel="nofollow noopener">https://github.com/MekayelAnik/nfs-server-alpine</a>
</p>
<p> For NFS related issues please visit: <a href="http://www.linux-nfs.org/wiki/index.php/Main_Page" rel="nofollow noopener">http://www.linux-nfs.org/wiki/index.php/Main_Page</a>
</p>