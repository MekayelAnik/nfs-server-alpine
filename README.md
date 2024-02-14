<h1>NFS Server multi-arch image</h1>
<p>A Multi-Aarch image for lightweight, highly customizable, containerized NFS server</p>
<img alt="NFS" src="https://linux-nfs.org/wiki/logo.png">
<p>This is an unofficial Multi-Aarch docker image of NFS Server created for multiplatform support. This image creates a local NFS Server to facilitate client-side data transfer. Official Website: <a href="https://wiki.linux-nfs.org" rel="nofollow noopener">https://wiki.linux-nfs.org</a>
</p>
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mekayelanik/nfs-server-alpine.svg"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/mekayelanik/nfs-server-alpine.svg">
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
<h2>Some Notes about NFS before you dive in:</h2>
    <p>- The first write after mounting the NFS-share takes sometime (Almost a minute). So if you immidiately try to write after mounting the share, it may seem it is hanged. But it is NOT. Give it some time.</p>
    <p>- If you continue to use the NFS you may run into a **NFS stale** problem. To solve this please see <a href="https://engineerworkshop.com/blog/automatically-resolve-nfs-stale-file-handle-errors-in-ubuntu-linux/" rel="nofollow noopener">THIS ARTICLE</a></p>
    <p>- One container can only share One parent Directory and all its nested sub-directories. But you can't use one container to share multiple Parent directories or Drives. For this you have to containers for each Parent Directory or Disk.</p> 
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
      - NFS_EXPORT_1=Movies
      - NFS_EXPORT_2=Music
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
#### To create More than one NFS server container, please use MACVLAN as given example below.
      - /mnt/drive1:/data
      - /mnt/drive1/Movies:/data/Movies
      - /mnt/drive1/Music:/data/Music
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
  -e NFS_EXPORT_1=Movies\
  -e NFS_EXPORT_2=Music\
  -e TZ=Asia/Dhaka \
  -e ALLOWED_CLIENT=192.168.1.1/24 \
  -v /mnt/drive1:/data \
  -v /mnt/drive1/Movies:/data/Movies \
  -v /mnt/drive1/Music:/data/Music \
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
      - NFS_EXPORT_1=Movies
      - NFS_EXPORT_2=Music
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
#### To create More than one NFS server container, please use MACVLAN as given example below.
      - /mnt/drive1:/data
      - /mnt/drive1/Movies:/data/Movies
      - /mnt/drive1/Music:/data/Music
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
      macvlan-docker:
        ipv4_address: 192.168.1.21
#### Network Defination ####
networks:
  macvlan-docker:
    name: macvlan-docker
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

<h3>If anyone wishes to give dedicated Local IP to NFS server container using MACVLAN ( <a href="https://docs.docker.com/network/macvlan/" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>---
version: "3.9"
services:
  nfs-server:
    image: mekayelanik/nfs-server-alpine:latest
    container_name: nfs-server
    environment:
      - TZ=Asia/Dhaka
      - ALLOWED_CLIENT=192.168.1.1/24
      - NFS_MOUNT_PORT=2049
# Number of Shares without ROOT DIR
      - NUMBER_OF_SHARES=2
      - NFS_EXPORT_1=Movies
      - NFS_EXPORT_2=Music
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
#### To create More than one NFS server container, please use MACVLAN as given example below.
      - /mnt/drive1:/data
      - /mnt/drive1/Movies:/data/Movies
      - /mnt/drive1/Music:/data/Music
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
        hostname: nfs-server
    domainname: local
    mac_address: 14-24-34-44-54-64
    networks:
      macvlan-docker:
        ipv4_address: 192.168.1.21
#### Network Defination ####
networks:
  macvlan-docker:
    name: macvlan-docker
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
<h3>If anyone wishes to give dedicated Local IP to NFS server container using MACVLAN ( <a href="https://docs.docker.com/network/macvlan/" rel="nofollow noopener">click here for more info</a>) </h3>
<h4>Creating A MACVLAN First. Example is Below</h4>
<pre><code>
docker network create -d macvlan \ 
    --subnet=192.168.0.0/16 \       ####    Set your Subnet here and remove this comment    ####
    --ip-range=192.168.1.0/16 \     ####    Set your Desired IP range fr this MACVLAN here. (You can set IP to your CONTAINERs from this range) and remove this comment    ####
    --gateway=192.168.0.1 \         ####    Set your Original Network Gateway or Router's Local IP here and remove this comment    ####
    -o parent=eth0 macvlan-docker   ####    Set your network interface in the "parent=" (In Raspberrypi parent is 'eth0' in mordern x86 systems it is 'enp4s0'. Find yours by running "tcpdump --list-interfaces" ) & desired MACVLAN Nework name in the end (Here I have set the name to macvlan-docker) IP here and remove this comment    ####
</code></pre>
<h4>Creating Container n MACVLAN. Example is Below</h4>
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
      - NFS_EXPORT_1=Movies
      - NFS_EXPORT_2=Music
    privileged: true
    volumes:
# # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
      - /lib/modules:/lib/modules
# NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
#### To create More than one NFS server container, please use MACVLAN as given example below.
      - /mnt/drive1:/data
      - /mnt/drive1/Movies:/data/Movies
      - /mnt/drive1/Music:/data/Music
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
      macvlan-docker:
        ipv4_address: 192.168.1.21
        #### Network Defination ####  
        networks:
          macvlan-docker:
            name: macvlan-docker
            external: True
</code></pre>

<h3>If anyone wishes to SHARE FROM MORE THAN ONE PARENT DIRECTORY please use this MACVLAN approch </h3>
<pre><code>---
    version: "3.9"
    services:
########### Conatiner for Share from Parent Direnctory-1 or Disk-1 ###########
        nfs-server-disk1:
            image: mekayelanik/nfs-server-alpine:latest
            container_name: nfs-server-disk1
            environment:
                - TZ=Asia/Dhaka
                - ALLOWED_CLIENT=192.168.1.1/24
                - NFS_MOUNT_PORT=2049
        # Number of Shares without ROOT DIR
                - NUMBER_OF_SHARES=2
                - NFS_EXPORT_1=Movies
                - NFS_EXPORT_2=Music
            privileged: true
            volumes:
            ### Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )  ###
                - /lib/modules:/lib/modules
        # NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
        ## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
        ### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
        #### To create More than one NFS server container, please use MACVLAN as given example below.
                - /mnt/drive1:/data
                - /mnt/drive1/Movies:/data/Movies
                - /mnt/drive1/Music:/data/Music
            ports:
                - 2049:2049
                - 111:111
                - 32765-32767:32765-32767
        ### Don't touch the FOLLOWING Section. This is REQUIRED to run NFS as a container (cap_add). ###
            cap_add:
                - SYS_ADMIN
                - SETPCAP
                - ALL
            restart: unless-stopped
            hostname: nfs-server-1
            domainname: local
            mac_address: ab-cd-ef-ab-cd-a1
            networks:
                macvlan-docker:
                    ipv4_address: 192.168.249.101
########### Conatiner for Share from Parent Direnctory-2 or Disk-2 ###########
        nfs-server-disk2:
            image: mekayelanik/nfs-server-alpine:latest
            container_name: nfs-server-disk2
            environment:
                - TZ=Asia/Dhaka
                - ALLOWED_CLIENT=192.168.1.1/24
                - NFS_MOUNT_PORT=2049
            # Number of Shares without ROOT DIR
                - NUMBER_OF_SHARES=2
                - NFS_EXPORT_1=Games
                - NFS_EXPORT_2=Softwares
            privileged: true
            volumes:
            # # Don't touch the FOLLOWING Mapping (/lib/modules). This is REQUIRED to run NFS as a container. ('sys_module' modprobe )
                - /lib/modules:/lib/modules
            # NFS Root directory in this container '/data' MUST BE MAPPED to a valid directory in the Host (Server Machine)
            ## You CAN'T use different parent directory (for example /mnt/drive2/Movies) for child shares.
            ### To share different Child shares on another Parent directory, you must use deploy another container. (Sorry, but this is how the NFS works)
            #### To create More than one NFS server container, please use MACVLAN as given example below.
                - /mnt/drive2:/data
                - /mnt/drive2/Games:/data/Games
                - /mnt/drive2/Softwares:/data/Softwares
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
            hostname: nfs-server-disk2
            domainname: local
            mac_address: ab-cd-ef-ab-cd-a2
            networks:
                macvlan-docker:
                    ipv4_address: 192.168.249.102
    #### Network Defination ####  
    networks:
      macvlan-docker:
        name: macvlan-docker
        external: True
</code></pre>
<h2>In order to mount NFS share run the Following on Client Machine</h2>
<pre><code># To mount ROOT_DIR
sudo mount -v -o vers=4.2,loud HOST-IP:/ /mount/path/to/ROOT-MOUNT-DIR
Example: sudo mount -v -o vers=4.2,loud 192.168.1.2:/ /mount/path/to/ROOT-MOUNT-DIR
# To mount Child Shares (via Command Line)
sudo mount -v -o vers=4.2,loud HOST-IP:/Movies /nfs_shares/Movies
sudo mount -v -o vers=4.2,loud HOST-IP:/Music /nfs_shares/Music
Example:  
mkdir -p /nfs_shares/Movies && \
sudo mount -v -o vers=4.2,loud 192.168.1.2:/Movies  /nfs_shares/Movies
</code></pre>
<h2> To Mount Using FSTAB, Add the following in the '/etc/fstab' </h2>
<pre><code> ##### NFS-Share Mounts #####
    192.168.249.101:/ /nfs_shares nfs nofail,noauto,x-systemd.automount
    192.168.249.101:/Movies /nfs_shares/Movies nfs nofail,noauto,x-systemd.automount
    192.168.249.101:/Music /nfs_shares/Music nfs nofail,noauto,x-systemd.automount
</code></pre>
<h2> To Un-mount</h2>
<pre><code>sudo umount  /nfs_shares/Movies
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
