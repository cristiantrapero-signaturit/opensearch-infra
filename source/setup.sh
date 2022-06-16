#! /bin/bash

# This script install all necesary to deploy a opensearch node usign docker
# This require SSM Parameters configured with the name, role and cluster name usign the private ip as identifier

# This file is for logging the setup actions
touch ~/setup.log

# Increase memory map areas up to 262144
# Doc: https://opensearch.org/docs/latest/opensearch/install/important-settings/
MAXMAP="vm.max_map_count=262144"

if ! test "$(grep $MAXMAP /etc/sysctl.conf)"
then
	echo "$MAXMAP" >> /etc/sysctl.conf
	sysctl -p
fi
echo "Increased max_map_count up to 262144" >> ~/setup.log

# Preserve the name 
# Doc: https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/
echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

echo "Preserved the ec2 hostname in cloud.cfg file" >> ~/setup.log

# Update the system
yum update -y
yum upgrade -y
yum clean all

# Install docker and enable it
yum install -y docker jq
service docker start
systemctl enable docker

echo "Docker installed" >> ~/setup.log

# Install docker-compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version

echo "Docker compose installed" >> ~/setup.log

# Get the node parameters
# 1. First search the ssm parameters by mi ip
export MYIP=$(hostname -I| awk '{print $1}')
export NODE_PARAMS=$(aws ssm get-parameter --region eu-west-1 --name $MYIP | jq -r '.Parameter.Value')

echo "Node SSM parameters: $NODE_PARAMS" >> ~/setup.log
export NODE_NAME=$(echo $NODE_PARAMS | cut -d ',' -f 1)
export NODE_ROLE=$(echo $NODE_PARAMS | cut -d ',' -f 2)
export CLUSTER_NAME=$(echo $NODE_PARAMS | cut -d ',' -f 3)

# 2. Get the seed hosts
export SEED_HOSTS=$(aws ssm get-parameter --region eu-west-1 --name initial_cluster_manager_nodes | jq -r '.Parameter.Value')

# 3. Get the master manager nodes
export MANAGER_NODES=$(aws ssm get-parameter --region eu-west-1 --name seed_hosts | jq -r '.Parameter.Value')

# Define the docker compose file of the service
if [ "${NODE_ROLE}" == "data" ] || [ "${NODE_ROLE}" == "cluster_manager" ]
then

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${NODE_NAME}:
    image: opensearchproject/opensearch:2.0.0
    container_name: ${NODE_NAME}
    environment:
      - cluster.name=${CLUSTER_NAME}
      - node.name=${NODE_NAME}
      - discovery.seed_hosts=${SEED_HOSTS}
      - cluster.initial_cluster_manager_nodes=${MANAGER_NODES}
      - network.publish_host=${MYIP}
      - node.roles=${NODE_ROLE}
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m" # minimum and maximum Java heap size, recommend setting both to 50% of system RAM
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - ${NODE_NAME}:/usr/share/opensearch/data
    restart: unless-stopped
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - opensearch-net
volumes:
  ${NODE_NAME}:
networks:
  opensearch-net:
EOT

else

cat <<EOT > ~/docker-compose.yml
version: '3'
services:
  ${NODE_NAME}:
    image: opensearchproject/opensearch-dashboards:2.0.0
    container_name: ${NODE_NAME}
    restart: unless-stopped
    volumes:
      - ${NODE_NAME}:/usr/share/opensearch/data
    environment:
      PLUGINS_SECURITY_DISABLED: "true"
      OPENSEARCH_HOSTS: '["https://ops-master-1.cristiantrapero.com:9200","https://ops-master-2.cristiantrapero.com:9200","https://ops-master-3.cristiantrapero.com:9200"]'
    ports:
      - 5601:5601
    expose:
      - "5601"
    networks:
      - opensearch-net
volumes:
  ${NODE_NAME}:
networks:
  opensearch-net:
EOT

fi

# Start docker compose
echo "Start docker compose service" >> ~/setup.log
docker-compose -f ~/docker-compose.yml up -d
echo "Start docker compose service...Done" >> ~/setup.log