<h1>ProFTPD multi-arch image</h1>
<img alt="ProFTPD" src="http://www.proftpd.org/proftpd.png">
<p>This is an unofficial multi-aarch docker image of ProFTPD created for multiplatform support.This image creates a local FTP server to ficilitate client-side data transfer. Official Website: <a href="http://www.proftpd.org" rel="nofollow noopener">http://www.proftpd.org/</a>
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
<p>This image provides various versions that are available via tags. Please read the <a href="http://www.proftpd.org/" rel="nofollow noopener">update information</a> carefully and exercise caution when using "older versions" tags as they tend to contain unfixed bugs. </p>
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
      <td>Stable "ProFTPD releases</td>
    </tr>
    <tr>
      <td align="center">1.3.8</td>
      <td align="center">✅</td>
      <td>Static "ProFTPD" build version 1.3.8</td>
    </tr>
  </tbody>
</table>
<h2>Running Image :</h2>
<p>Here are some example snippets to help you get started creating a container.</p>
<h3>docker-compose (recommended, <a href="https://itnext.io/a-beginners-guide-to-deploying-a-docker-application-to-production-using-docker-compose-de1feccd2893" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>---
version: "3.9"
services:
  proftpd-server-alpine:
    image: mekayelanik/proftpd-server-alpine:latest
    container_name: proftpd-server-alpine
    environment:
      - TZ=Asia/Dhaka
      - FTP_PORT=21
      - NUMBER_OF_SHARES=4
      - FTP_SHARE_1=SHARE_1
      - FTP_PASSWORD_1=PASS_1
      - FTP_SHARE_1_PUID=1001
      - FTP_SHARE_1_PGID=1001
      - FTP_SHARE_2=SHARE_2
      - FTP_PASSWORD_2=PASS_2
      - FTP_SHARE_2_PUID=1002
      - FTP_SHARE_2_PGID=1002
      - FTP_SHARE_3=SHARE_3
      - FTP_PASSWORD_3=PASS_3
      - FTP_SHARE_3_PUID=1003
      - FTP_SHARE_3_PGID=1003
      - FTP_SHARE_4=SHARE_4
      - FTP_PASSWORD_4=PASS_4
      - FTP_SHARE_4_PUID=1004
      - FTP_SHARE_4_PGID=1004
    volumes:
      - /mnt/Vol1:/data/SHARE_1     
      - /mnt/Vol1:/data/SHARE_2
      - /mnt/Vol1:/data/SHARE_3
      - /mnt/Vol1:/data/SHARE_4
    restart: unless-stopped
</code></pre>
<h3>docker cli ( <a href="https://docs.docker.com/engine/reference/commandline/cli/" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>docker run -d \
  --name=proftpd-server-alpine \
  -e TZ=Asia/Dhaka \
  -e FTP_PORT=21 \
  -e NUMBER_OF_SHARES=4 \
  -e FTP_SHARE_1=SHARE_1 \
  -e FTP_PASSWORD_1=PASS_1 \
  -e FTP_SHARE_1_PUID=1001 \
  -e FTP_SHARE_1_PGID=1001 \
  -e FTP_SHARE_2=SHARE_2 \
  -e FTP_PASSWORD_2=PASS_2 \
  -e FTP_SHARE_2_PUID=1002 \
  -e FTP_SHARE_2_PGID=1002 \
  -e FTP_SHARE_3=SHARE_3 \
  -e FTP_PASSWORD_3=PASS_3 \
  -e FTP_SHARE_3_PUID=1003 \
  -e FTP_SHARE_3_PGID=1003 \
  -e FTP_SHARE_4=SHARE_4 \
  -e FTP_PASSWORD_4=PASS_4 \
  -e FTP_SHARE_4_PUID=1004 \
  -e FTP_SHARE_4_PGID=1004 \
  -v /mnt/Vol1:/data/SHARE_1 \
  -v /mnt/Vol1:/data/SHARE_2 \
  -v /mnt/Vol1:/data/SHARE_3 \
  -v /mnt/Vol1:/data/SHARE_4 \
  --restart unless-stopped \
  mekayelanik/proftpd-server-alpine:latest
</code></pre>

<h3>If anyone wishes to give dedicated Local IP to ProFTPD container using MACVLAN ( <a href="https://docs.docker.com/network/macvlan/" rel="nofollow noopener">click here for more info</a>) </h3>
<pre><code>---
version: "3.9"
services:
  proftpd-server-alpine:
    image: mekayelanik/proftpd-server-alpine:latest
    container_name: proftpd-server-alpine
    environment:
      - TZ=Asia/Dhaka
      - FTP_PORT=21
      - NUMBER_OF_SHARES=4
      - FTP_SHARE_1=SHARE_1
      - FTP_PASSWORD_1=PASS_1
      - FTP_SHARE_1_PUID=1001
      - FTP_SHARE_1_PGID=1001
      - FTP_SHARE_2=SHARE_2
      - FTP_PASSWORD_2=PASS_2
      - FTP_SHARE_2_PUID=1002
      - FTP_SHARE_2_PGID=1002
      - FTP_SHARE_3=SHARE_3
      - FTP_PASSWORD_3=PASS_3
      - FTP_SHARE_3_PUID=1003
      - FTP_SHARE_3_PGID=1003
      - FTP_SHARE_4=SHARE_4
      - FTP_PASSWORD_4=PASS_4
      - FTP_SHARE_4_PUID=1004
      - FTP_SHARE_4_PGID=1004
    volumes:
      - /mnt/Vol1:/data/SHARE_1     
      - /mnt/Vol1:/data/SHARE_2
      - /mnt/Vol1:/data/SHARE_3
      - /mnt/Vol1:/data/SHARE_4
    restart: unless-stopped
        hostname: proftpd-server
    domainname: local
    mac_address: 45-45-45-45-45-45
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
<h2>Updating Info</h2>
<p>Below are the instructions for updating containers:</p>
<h3>Via Docker Compose (recommended)</h3>
<ul>
  <li>Update all images: <code>docker compose pull</code>
    <ul>
      <li>or update a single image: <code>docker compose pull mekayelanik/proftpd-server-alpine</code>
      </li>
    </ul>
  </li>
  <li>Let compose update all containers as necessary: <code>docker compose up -d</code>
    <ul>
      <li>or update a single container (recommended): <code>docker compose up -d proftpd-server-alpine</code>
      </li>
    </ul>
  </li>
  <li>To remove the old unused images run: <code>docker image prune</code>
  </li>
</ul>
<h3>Via Docker Run</h3>
<ul>
  <li>Update the image: <code>docker pull mekayelanik/proftpd-server-alpine:latest</code>
  </li>
  <li>Stop the running container: <code>docker stop proftpd-server-alpine</code>
  </li>
  <li>Delete the container: <code>docker rm proftpd-server-alpine</code>
  </li>
  <li>Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your <code>/AgentDVR/Media/XML</code> folder and settings will be preserved) </li>
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
--run-once proftpd-server-alpine</code></pre>
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
<p> To submit this Docker image specific issues or requests visit this docker image's Github Link: <a href="https://github.com/MekayelAnik/proftpd-server-alpine" rel="nofollow noopener">https://github.com/MekayelAnik/proftpd-server-alpine</a>
</p>
<p> For Proftpd related issues and requests, please visit: <a href="https://github.com/proftpd/proftpd" rel="nofollow noopener">https://github.com/proftpd/proftpd/</a>
</p>