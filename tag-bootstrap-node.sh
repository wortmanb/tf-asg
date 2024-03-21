#!/bin/bash
#
# I still need to make this take in an IP and determine the instance from that.
#
#
function usage() {
      cat <<EOF
Usage:

tag-bootstrap-node.sh instance_id cluster_name

EOF
exit 1
}

[[ $# -ne 1 ]] && usage

aws ec2 create-tags --tags "Key=NODE_ROLES,Value=bootstrap" "Key=CLUSTER_NAME,Value=${2}" --resources ${1}
