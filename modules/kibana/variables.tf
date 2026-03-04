variable "tags" {
  type = map(string)
}

variable "asg_specific_tags" {
  type = map(string)
  default = {
    NODE_ROLES = "kibana"
  }
}

variable "desired" {
  type = number
}

variable "min" {
  type = number
}

variable "max" {
  type = number
}

variable "key_pair" {
  type = string
  default = "bdw-test-kp"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami_id" {
  type = string
  default = "ami-0c101f26f147fa7fd"
}

variable "install_type" {
  type = string
  default = "kibana"
}

variable "subnets" {
  type = list(string)
  default = [ "subnet-0449011342c679f55", "subnet-096499b2a566162af", "subnet-0cdd62554724ce9f0" ]
}

variable "security_group_names" {
  type = list(string)
  default = [ "default" ]
}

variable "security_group_ids" {
  type = list(string)
  default = [ "sg-0e877fae75357a7b1" ]
}

# aws s3 path is hardcoded for now. We need to update this but had issues
# when overriding the script during initialize commands.

variable "user_data_script" {
  type = string
  default = <<EOT
#!/bin/bash
echo "version 4.2" > /tmp/setup.output

id >> /tmp/setup.output

export AWS_DEFAULT_REGION="us-iso-east-1"

env >> /tmp/setup.output

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

aws s3 --no-verify-ssl cp s3://my-s3-bucket/path-to-scripts-FIXME/scripts/kibana-setup.bash /tmp >> /tmp/setup.out 2>&1
chmod +x /tmp/kibana-setup.bash
cd /tmp
./kibana-setup.bash >> /tmp/setup.out 2>&1
EOT
}
