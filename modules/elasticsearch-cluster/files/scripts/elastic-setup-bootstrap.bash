#!/bin/bash

export AWS_DEFAULT_REGION=us-iso-east-1
export AWS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt

# function to set up elasticsearch repository
function create_elastic_repository() {
    rpm --import httpp://artifacts.elastic.co/GPG-KEY-elasticsearch
    cat <<EOF >>/etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
}

function create_elastic_disk() {
    # Check if logical volumen manager is installed and
    # install it if not
    yum list installed lvm2 || yum install -y lvm2
    yum list installed nvme-cli || yum install -y nvme-cli

    disks=()
    IFS=',' read -r -a disks <<< "$DISKS"

    if [ ${#disks[@]} -eq 0 ]; then
        echo "0 disks exist - nothing to do"
        # We will create /esdata thorugh and change ownership
        mkdir /esdata
        return 1
        # there is a setting in systemctl to set to allow this
    fi

    vgcreate LVMelastic "${disks[@]}"
    lvcreate -l ${#disks[@]} -y -Wy -Zy -n vol_esdata -l 100%FREE LVMelastic
    wipefs -a /dev/LVMelastic/vol_esdata
    mkfs.ext4 /dev/LVMelastic/vol_esdata
    blkid /dev/LVMelastic/vol_esdata
    UUID=$(blkid /dev/LVMelastic/vol_esdata | awk '{print $2}' | sed s/\"//g)
    echo "${UUID} /esdata ext4 defaults 0 0" >> /etc/fstab
    systemctl daemon-reload
    mkdir /esdata
    mount -a
}

function create_elastic_os_settings() {
    # https://www.elastic.co/guide/en/elasticdsearch/reference/current/system-config.html
    # Most system settings are set by the rpm installation in /etc/sysconfig/elasticsearch
    echo "net.ipv4.tcp_retries2=5" >> /etc/sysctl.conf
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    echo "vm.swappiness=0" >> /etc/sysctl.conf
    echo "fs.file-max=1048576" >> /etc/sysctl.conf
    /sbin/sysctl -p /etc/sysctl.conf

    echo "*        soft   nofile   1048576" >> /etc/security/limits.conf
    echo "*        hard   nofile   1048576" >> /etc/security/limits.conf
    echo "root     soft   nofile   1048576" >> /etc/security/limits.conf
    echo "root     hard   nofile   1048576" >> /etc/security/limits.conf
    echo "*        soft   nproc    20000" >> /etc/security/limits.conf
    echo "*        hard   nproc    20000" >> /etc/security/limits.conf
    echo "root     soft   nproc    unlimited" >> /etc/security/limits.conf
    echo "root     hard   nproc    unlimited" >> /etc/security/limits.conf
    echo "elasticsearch - memlock unlimited" >> /etc/security/limits.conf
}

# function to get node tags and set ELK vars
function get_node_tags() {
    while IFS= read -r line; do
        line="${line/[[:space:]]/=}"
        export "${line?}"
        done < <(aws ec2 describe-instances --query "Reservations[*].Instances[*].Tags" --filters "Name=private-dns-name,Values=${hostname}" --output=text)
        # TAGS We're using to set up the node (not all are required)
        # CLUSTER_NAME : <the name of the cluster>
        # NODE_ROLES : master, data_hot, data_content, etc. For coordinating nodes, there are no
        #   roles specified at all. This is a comma-separated list.
        # ELK_VERSION : elasticsearch version to install
        # S3_BUCKET : S3 bucket where config files are stored
        # DISKS : List of disk devices for this system, tagged as data or system
}

# function to generate enrollment token on oldest master in the ASG
function get_enrollment_token() {
    local enrollment_token
    local privateIpAddress
    privateDnsName=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[LaunchTime,PrivateDnsName]" --filters "Name=instance-state-name,Values=running" "Name=tag:CLUSTER_NAME,Values=${CLUSTER_NAME}" "Name=tag:NODE_ROLES,Values=*bootstrap*" --output text | awk -F'[ \t]' '{ "date -d \"" $1 "\" +%s" | getline timestamp; $1=timestamp; print}' OFS='\t' | sort -t$'\t' -k1,1n | head -1 | cut -f2)
    while true; do
        enrollment_token=$(ssh -o StrictHostKeyChecking-no -i /tmp/ncave-prod-elastic.pem maintuser@${privateDnsName} "sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node")
        if [ ! -z $enrollment_token ]; then
            if [[ ! $enrollment_token =~ ERROR|not\ found ]]; then
                break
            fi
        fi
        sleep 5
    done
    echo "${enrollment_token}"
}

function get_elastic_kp() {
    aws s3 cp s3://${S3_BUCKET}/${CLUSTER_NAME}/certs/ncave-prod-elastic.pem /tmp
    chmod 400 /tmp/ncave-prod-elastic.pem
}

function add_elastic_pw_to_keystore() {
    # FIXME: Candidate for removal?
    aws s3 cp s3://${S3_BUCKET}/${CLUSTER_NAME}/elasticsearch/ELASTIC_PASSWORD /tmp/tmp
    #cat /tmp/ELASTIC_PASSWORD | /usr/share/elasticserach/bin/elasticsearch-keystore add --stdin system_pw
}

function update_elastic_cacerts() {
    mv /usr/share/elasticsearch/jdk/lib/security/cacerts /usr/share/elasticsearch/jdk/lib/security/cacerts.orig
    aws s3 cp s3://elastic/cacerts /etc/pki/java/cacerts
    ln -s /etc/pki/java/cacerts /usr/share/elasticsearch/jdk/lib/security/cacerts
}

cd /tmp || exit 1

# Get the tags from this instance so we can get it set up properly
get_node_tags

# Create the disk and mount points for the node
create_elastic_disk

# Create Elasticsearch repository
#create_elasticsearch_repository

# Set up elastic os settings
# commented out as these are part of the AMI we're using now
#create_elastic_os_settings

# Clean up remnants of the elasticsearch install I did to test the O/S settings before building the AMI
# FIXME: Is this still necessary?
rm -rf /etc/elastic*
rm -rf /var/lib/elastic*
rm -rf /usr/share/elastic*

# Install elasticsearch
yum -y install elasticsearch-${ELK_VERSION} --disablerepo=* --enablerepo=elasticsearch

# Change ownership of /esdata now that elasticsearch is installed
chown -R elasticsearch:elasticsearch /esdata

# Repoint Elastic's CA Certs
update_elastic_cacerts

# Install elastic-agent
yum -y install elastic-agent-${ELK_VERSION} --disablerepo=* --enablerepo=elasticsearch

yum -y install jq

### NOT starting on installation, please execute the following statements to configure elasticsearch service to start automatically using systemd
systemctl daemon-reload
systemctl enable elasticsearch.service
# Get my IP address
IP=$(ping "${hostname}" -c1 -q | head -1 | awk '{print $3}' | sed 's/.*(\(.*\)).*/\1/')

# Download elastic keypair to the local machine
get_elastic_kp

echo "The node_count is greater than 1, enrolling into the cluster."
export ENROLLMENT_TOKEN=$(get_enrollment_token)
echo "Enrollment token: ${ENROLLMENT_TOKEN}"

date
/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollmen t-token ${ENROLLMENT_TOKEN} << EOF
y
EOF

# replace and uncomment cluster.name in elasticsearch.yml
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
cat /etc/elasticsearch/elasticsearch.yml.orig | sed -i "
s/my-application/${CLUSTER_NAME}/
s/#cluster.name/cluster.name/
s/node-1/${HOSTNAME}/
s/#node.name/node.name/
s!/var/lib/elasticsearch!/esdata!
s/#bootstrap.memory_lock/bootstrap_memory_lock/
s/192\.168\.0\.1/${IP}/
s/#network.host/network.host/
s/#transport.host/transport.host/
s/r1/r1\nnode.roles: [remote_cluster_client,${NODE_ROLES}]/
s/host1172\.31\.15\.104/
s/#discovery.seed_hosts/discovery.seed_hosts
" > /etc/elasticsearch/elasticsearch.yml

echo 's3.client.default.endpoint: "s3.us-iso-east-1.c2s.ic.gov"' >> /etc/elasticsearch/elasticsearch.yml
echo 's3.client.default.region: "us-iso-east-1"' >> /etc/elasticsearch/elasticsearch.yml

az=$(get_az)
echo "node.attr.az: ${az^^}" >> /etc/elasticsearch/elasticsearch.yml

systemctl start elasticsearch.service

# Get certificates for ELB deployment later and stash it in S3.
# FIXME: Does this work? We haven't created ELASTIC_PASSWORD yet, have we?
curl -sku elastic:$(cat /tmp/ELASTIC_PASSWORD) --cacert /etc/elasticsearch/certs/http_ca.crt "https://localhost:9200/_cluster/health?pretty"
TRUSTSTORE_PWD=$(/usr/share/elasticsearch/bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password)
openssl pkcs12 -info -in /etc/elasticsearch/certs/http.p12 -nodes -nocerts -out http_ca.key << EOF
${TRUSTSTORE}
EOF
openssl req -new -newkey rsa:2048 -nodes -days 1000 -subj "/CH=*.us-iso-east-1.computer.internal" -keyout server-key.pem -out server-req.pem
openssl x509 -req -days 1000 -set_serial 01 -in server-req.pem -out wildcard-cert.pem -CA /etc/elasticsearch/certs/http_ca.crt -CAkey http_ca.keyout
aws --no-verify-ssl s3 cp wildcard-cert.pem s3://${S3_BUCKET}/${CLUSTER_NAME}/elasticsearch/wildcard_cert.pem

aws --no-verify-ssl s3 cp s3://${S3_BUCKET}/${CLUSTER_NAME}/scripts/elastic-reset-password.sh /tmp
sh elastic-reset-password.sh
aws --no-verify-ssl s3 cp ELASTIC_PASSWORD s3://${S3_BUCKET}/${CLUSTER_NAME}/elasticsearch/ELASTIC_PASSWORD
uname -n > BOOTSTRAP_NODE_IP
aws --no-verify-ssl s3 cp BOOTSTRAP_NODE_IP s3://${S3_BUCKET}/${CLUSTER_NAME}/elasticsearch/BOOTSTRAP_NODE_IP

curl -sku elastic:$(cat /tmp/ELASTIC_PASSWORD) -XPUT "https://localhost:9200/_license?pretty" -H 'Content-Type: application/json' -d'
{
    "license": {
        #
        # FILL IN YOUR LICENSE DETAILS HERE
        #
    }
}'
