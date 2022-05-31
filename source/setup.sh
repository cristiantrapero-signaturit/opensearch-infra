#! /bin/bash

touch ~/setup.log
chmod 777 ~/setup.log

echo "Node name: ${node_name}" >> ~/setup.log
echo "Node role: ${node_role}" >> ~/setup.log
echo "Cluster name: ${cluster_name}" >> ~/setup.log
echo "Domain: ${domain}" >> ~/setup.log
echo "Basic config" >> ~/setup.log

# Persist config
maxmap="vm.max_map_count=262144"
if ! test "$(grep $maxmap /etc/sysctl.conf)"
then
	echo "$maxmap" >> /etc/sysctl.conf
	sysctl -p
fi

hostname "${node_name}"
export ipaddr=$(hostname -I)
yum install -y docker
service docker start
systemctl enable docker

# Install docker-compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version

if [[ "${node_role}" == "data" ]]
then
cat <<EOT > ~/opensearch.yml
cluster.name: ${cluster_name}
node.name: ${node_name}
discovery.seed_hosts: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}","ops-data-1.${domain}","ops-data-2.${domain}","ops-dashboard.${domain}"]
network.publish_host: $ipaddr
node.roles: [ data, ingest ]
EOT

chmod 777 ~/opensearch.yml

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch:2.0.0
    container_name: ${node_name}
    environment:
      - bootstrap.memory_lock=true # along with the memlock settings below, disables swapping
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m" # minimum and maximum Java heap size, recommend setting both to 50% of system RAM
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536 # maximum number of open files for the OpenSearch user, set to at least 65536 on modern systems
        hard: 65536
    volumes:
      - ${node_name}:/usr/share/opensearch/data
      - ./opensearch.yml:/usr/share/opensearch/config/opensearch.yml
    restart: unless-stopped
    ports:
      - 9200:9200
      - 9300:9300
      - 9600:9600 # required for Performance Analyzer
    networks:
      - opensearch-net

volumes:
  ${node_name}:

networks:
  opensearch-net:
EOT
  echo "Start docker compose service" >> ~/setup.log
  docker-compose -f ~/docker-compose.yml up -d
  echo "Start docker compose service...Done" >> ~/setup.log
fi

if [[ "${node_role}" == "master" ]]
then
cat <<EOT > ~/opensearch.yml
cluster.name: ${cluster_name}
node.name: ${node_name}
discovery.seed_hosts: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}","ops-data-1.${domain}","ops-data-2.${domain}","ops-dashboard.${domain}"]
network.publish_host: $ipaddr
node.roles: [ cluster_manager ]
EOT

chmod 777 ~/opensearch.yml

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch:2.0.0
    container_name: ${node_name}
    environment:
      - bootstrap.memory_lock=true # along with the memlock settings below, disables swapping
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m" # minimum and maximum Java heap size, recommend setting both to 50% of system RAM
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536 # maximum number of open files for the OpenSearch user, set to at least 65536 on modern systems
        hard: 65536
    volumes:
      - ${node_name}:/usr/share/opensearch/data
      - ./opensearch.yml:/usr/share/opensearch/config/opensearch.yml
    restart: unless-stopped
    ports:
      - 9200:9200
      - 9300:9300
      - 9600:9600 # required for Performance Analyzer
    networks:
      - opensearch-net

volumes:
  ${node_name}:

networks:
  opensearch-net:
EOT


    if [[ "${node_name}" == "ops-master-1.${domain}" ]]
    then
        # Create the certificates
        echo "Generating certificates..." >> ~/setup.log
        #./generate-certificates.sh
        echo "Generating certificates... Done" >> ~/setup.log
        echo "Distribute certificates to nodes" >> ~/setup.log
    fi

  echo "Start docker compose service" >> ~/setup.log
  docker-compose -f ~/docker-compose.yml up -d
  echo "Start docker compose service...Done" >> ~/setup.log
fi

if [ "${node_role}" == "dashboard" ]
then
cat <<EOT > ~/opensearch_dashboards.yml
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Description:
# Default configuration for OpenSearch Dashboards

opensearch.hosts: ["https://ops-master-1.${domain}:9200","https://ops-master-2.${domain}:9200","https://ops-master-3.${domain}:9200"]
opensearch.ssl.verificationMode: none
opensearch.username: "admin"
opensearch.password: "adminadmin"
opensearch.requestHeadersWhitelist: [ authorization,securitytenant ]

opensearch_security.multitenancy.enabled: true
opensearch_security.multitenancy.tenants.preferred: ["Private", "Global"]
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
# Use this setting if you are running kibana without https
opensearch_security.cookie.secure: false
server.host: ${node_name}
EOT

chmod 777 ~/opensearch_dashboards.yml

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch-dashboards:2.0.0
    container_name: ${node_name}
    restart: unless-stopped
    volumes:
      - ${node_name}:/usr/share/opensearch/data
      - ./opensearch_dashboards.yml:/usr/share/opensearch-dashboards/config/opensearch_dashboards.yml
    ports:
      - 5601:5601
    expose:
      - "5601"
    networks:
      - opensearch-net

volumes:
  ${node_name}:

networks:
  opensearch-net:
EOT

  echo "Start docker compose service" >> ~/setup.log
  docker-compose -f ~/docker-compose.yml up -d
  echo "Start docker compose service...Done" >> ~/setup.log

fi