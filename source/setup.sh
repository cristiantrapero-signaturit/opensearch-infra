#! /bin/bash

touch ~/setup.log
chmod 777 ~/setup.log

# Check if it is a first time setup
FILE=~/first_install
if [ -f "$FILE" ]; then
    echo "$FILE exist. Existing setup."
    exit 0
fi

echo "Node name: ${node_name}" >> ~/setup.log
echo "Node role: ${node_role}" >> ~/setup.log
echo "Cluster name: ${cluster_name}" >> ~/setup.log
echo "Domain: ${domain}" >> ~/setup.log
echo "Path to data: ${path_to_data}" >> ~/setup.log
echo "Basic config" >> ~/setup.log
sysctl -w vm.max_map_count=262144
hostname "${node_name}"
export ipaddr=$(hostname -I)
yum install -y docker
service docker start
service docker enable

if [[ "${node_role}" == "data" ]]
then
cat <<EOT > ~/opensearch.yml
cluster.name: ${cluster_name}
node.name: ${node_name}
discovery.seed_hosts: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}","ops-data-1.${domain}","ops-data-2.${domain}","ops-dashboard.${domain}"]
cluster.initial_master_nodes: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}"]
network.host: $ipaddr
path.data: ${path_to_data}
EOT

    if [[ "${node_name}" == "ops-master-1" ]]
    then
        # Create the certificates
        ./generate-certificates.sh
    fi
fi

if [[ "${node_role}" == "master" ]]
then
cat <<EOT > ~/opensearch.yml
cluster.name: ${cluster_name}
node.name: ${node_name}
discovery.seed_hosts: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}","ops-data-1.${domain}","ops-data-2.${domain}","ops-dashboard.${domain}"]
cluster.initial_master_nodes: ["ops-master-1.${domain}","ops-master-2.${domain}","ops-master-3.${domain}"]
network.host: $ipaddr
path.data: ${path_to_data}
EOT

    if [[ "${node_name}" == "ops-master-1.${domain}" ]]
    then
        # Create the certificates
        #./generate-certificates.sh
        echo "Generating certificates..." >> ~/setup.log
    fi
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
opensearch.password: "admin"
opensearch.requestHeadersWhitelist: [ authorization,securitytenant ]

opensearch_security.multitenancy.enabled: true
opensearch_security.multitenancy.tenants.preferred: ["Private", "Global"]
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
# Use this setting if you are running kibana without https
opensearch_security.cookie.secure: false
server.host: ${node_name}
EOT
fi