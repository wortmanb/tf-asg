#
# GLOBAL VALUES
#
# Set cluster_name to whatever name you want this cluster to be known as.
#
cluster_name = "tftf"
#
# What version of the Elastic stck are we installing?
#
elk_version = "8.12.2"
#
# What bucket contains the reference details for our clusters?
#
s3_bucket = "my-clusters"
#
# How long should we wait after starting the bootstrap ASG before adding more?
# This helps the bootstrap node come up before others start hammering it with
# enrollment token requests.
#
bootstrap_sleep = "2m"
#
# Remote cluster clients? Set this to true if you want all nodes to get the
# remote_cluster_client role in addition to their others.
# NOT IMPLEMENTED YET
#remote_cluster_client = false
#
#------------------------------------------------------------------------------
#
# NODE TYPES / TIERS
#
# The following values can be specified for each node type. Defaults are in
# parentheses:
#   min           (0) Minimum ASG size
#   max           (0) Maximum ASG size
#   desired       (0) Initial size for the ASG
#   roles         (none) what role should be applied to these nodes?
#   block_devices (onen system drive) what block devices should be applied
#   instance_type (*)  AWS instance type specification
#
# These values are used to initialize the ASGs and can be changed later. We
# suggest making the sizing changes through Terraform so that state can be
# tracked properly.
#
#------------------------------------------------------------------------------
#
# Bootstrap node
#
bootstrap = {
    desired = 1
    max = 1
}
#
# Master nodes
#
master = {
    min = 0 #3
    max = 3
    desired = 0 #3
    roles = "master"
    instance_type = "t2.micro"
}
#
# Content nodes
#
content = {
    min = 0 #3
    max = 3
    desired = 0 #3
    roles = "data_content"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Hot data nodes
#
hot = {
    min = 0 #3
    max = 3
    desired = 0 #0 #3
    roles = "data_hot"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
# The following is an example block_devices array with a 200GB system device and
# a 3 TB data device.
#    block_devices = [{
#        name = "/dev/xvda"
#        size = 200
#        purpose = "system"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdb"
#        size = 3000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    }]
}
#
# Warm data nodes
#
warm = {
    min = 0
    max = 0
    desired = 0
    roles = "data_warm"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Cold data nodes
#
cold = {
    min = 0
    max = 3
    desired = 0 #3
    roles = "data_cold"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
# The following is an example block_devices array with a 200GB system device and
# two 13 TB data devices.
#    block_devices = [{
#        name = "/dev/xvda"
#        size = 200
#        purpose = "system"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdb"
#        size = 13000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdc"
#        size = 13000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    }]
}
#
# Frozen data nodes
#
frozen = {
    min = 0
    max = 3
    desired = 0 #3
    roles = "data_frozen"
    instance_type = "i3en.2xlarge"
    instance_type = "t2.micro"
# The following is an example block_devices array with a 200GB system device and
# three 13 TB data devices.
#    block_devices = [{
#        name = "/dev/xvda"
#        size = 200
#        purpose = "system"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdb"
#        size = 13000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdc"
#        size = 13000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    },
#    {
#        name = "/dev/xvdd"
#        size = 13000
#        purpose = "data"
#        type = "gp2"
#        delete_on_termination = true
#    }]
}
#
# Ingest nodes
#
ingest = {
    min = 0
    max = 0
    desired = 0
    roles = "ingest"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Coordinator nodes
#
coordinator = {
    min = 0
    max = 3
    desired = 0 #3
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Machine Learning nodes
#
ml = {
    min = 0
    max = 3
    desired = 0 #3
    roles = "ml"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Transform nodes
#
transform = {
    min = 0
    max = 0
    desired = 0
    roles = "transform"
    instance_type = "t2.micro"
#    instance_type = "i3en.2xlarge"
}
#
# Kibana nodes
#
kibana = {
    min = 0
    max = 1
    desired = 1
    instance_type = "t2.micro"
#    instance_type = "r5n.2xlarge"
}
