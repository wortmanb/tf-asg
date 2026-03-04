module "create_aws_autoscaling_group" {
  source = "../elastic/asg"
  asg_specific_tags = {
    NODE_ROLES = var.roles
  }
  tags = var.tags
  desired_capacity = var.desired
  maximum_capacity = var.max
  instance_type = var.instance_type
  block_devices = var.block_devices
  user_data_script = <<EOT
#!/bin/bash
echo "version 4.2" > /tmp/setup.output

id >> /tmp/setup.output

export AWS_DEFAULT_REGION="us-iso-east-1"

env >> /tmp/setup.out

cat <<EOF >/etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch current version repo
baseurl=http://yum.our.net/elasticsearch/latest
gpgkey=http://yum.our.net/elasticsearch/GPG-KEY-elasticsearch
gpgcheck=0
enabled=1
skip_if_unavailable=1

[elasticsearch-8]
name=Elasticsearch 8.x repo
baseurl=http://yum.our.net/elasticsearch/8
gpgkey=http://yum.our.net/elasticsearch/GPG-KEY-elasticsearch
gpgcheck=0
enabled=0
skip_if_unavailable=1
EOF

aws s3 --no-verify-ssl cp s3://my-s3-bucket/${var.tags.CLUSTER_NAME}/scripts/elastic-setup-bootstrap.bash /tmp >> /tmp/setup.out 2>&1
chmod +x /tmp/elastic-setup-bootstrap.bash
cd /tmp
./elastic-setup-bootstrap.bash >> /tmp/setup.out 2>&1
EOT 
}
