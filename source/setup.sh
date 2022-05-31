#! /bin/bash

touch ~/setup.log
chmod 777 ~/setup.log

echo "Node name: ${node_name}" >> ~/setup.log
echo "Node role: ${node_role}" >> ~/setup.log
echo "Cluster name: ${cluster_name}" >> ~/setup.log
echo "Domain: ${domain}" >> ~/setup.log

# Persist config
maxmap="vm.max_map_count=262144"
if ! test "$(grep $maxmap /etc/sysctl.conf)"
then
	echo "$maxmap" >> /etc/sysctl.conf
	sysctl -p
fi

echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
hostnamectl set-hostname "${node_name}"
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

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch:2.0.0
    container_name: ${node_name}
    environment:
      - cluster.name=${cluster_name}
      - node.name=${node_name}
      - discovery.seed_hosts=ops-master-1.${domain},ops-master-2.${domain},ops-master-3.${domain},ops-data-1.${domain},ops-data-2.${domain},ops-dashboard.${domain}
      - cluster.initial_master_nodes=ops-master-1.${domain},ops-master-2.${domain},ops-master-3.${domain}
      - network.publish_host=$ipaddr
      - node.roles=data,ingest
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
cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch:2.0.0
    container_name: ${node_name}
    environment:
      - cluster.name=${cluster_name}
      - node.name=${node_name}
      - discovery.seed_hosts=ops-master-1.${domain},ops-master-2.${domain},ops-master-3.${domain},ops-data-1.${domain},ops-data-2.${domain},ops-dashboard.${domain}
      - cluster.initial_master_nodes=ops-master-1.${domain},ops-master-2.${domain},ops-master-3.${domain}
      - network.publish_host=$ipaddr
      - node.roles=cluster_manager
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
cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${node_name}:
    image: opensearchproject/opensearch-dashboards:2.0.0
    container_name: ${node_name}
    restart: unless-stopped
    volumes:
      - ${node_name}:/usr/share/opensearch/data
    environment:
      PLUGINS_SECURITY_DISABLED: "true"
      OPENSEARCH_HOSTS: '["https://ops-master-1.opensearch.local:9200","https://ops-master-2.opensearch.local:9200","https://ops-master-3.opensearch.local:9200"]'
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