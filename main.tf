module "elasticsearch_cluster" {
  source = "./modules/elasticsearch-cluster"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
}

module "elasticsearch_bootstrap" {
  source = "./modules/elasticsearch-bootstrap-node"
  tags= {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = "bootstrap"
  desired = var.bootstrap.desired
  max = var.bootstrap.max
  instance_type = "i3en.2xlarge"
}

resource "time_sleep" "wait_for_bootstrap" {
  depends_on = [ module.elasticsearch_bootstrap ]
  create_duration = var.bootstrap_sleep
}

module "elasticsearch_masters" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = var.master.roles
  min = var.master.min
  desired = var.master.desired
  max = var.master.max
  block_devices = var.master.block_devices
  instance_type = var.master.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_content_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
    DISKS = join(",", [for disk in var.content.block_devices : disk.name if disk.purpose == "data"])
  }
  roles = var.content.roles
  min = var.content.min
  desired = var.content.desired
  max = var.content.max
  block_devices = var.content.block_devices
  instance_type = var.content.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_hot_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
    DISKS = join(",", [for disk in var.hot.block_devices : disk.name if disk.purpose == "data"])
  }
  roles = var.hot.roles
  min = var.hot.min
  desired = var.hot.desired
  max = var.hot.max
  block_devices = var.hot.block_devices
  instance_type = var.hot.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_warm_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
    DISKS = join(",", [for disk in var.warm.block_devices : disk.name if disk.purpose == "data"])
  }
  roles = var.warm.roles
  min = var.warm.min
  desired = var.warm.desired
  max = var.warm.max
  block_devices = var.warm.block_devices
  instance_type = var.warm.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_cold_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
    DISKS = join(",", [for disk in var.cold.block_devices : disk.name if disk.purpose == "data"])
  }
  roles = var.cold.roles
  min = var.cold.min
  desired = var.cold.desired
  max = var.cold.max
  block_devices = var.cold.block_devices
  instance_type = var.cold.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_frozen_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
    DISKS = join(",", [for disk in var.frozen.block_devices : disk.name if disk.purpose == "data"])
  }
  roles = var.frozen.roles
  min = var.frozen.min
  desired = var.frozen.desired
  max = var.frozen.max
  block_devices = var.frozen.block_devices
  instance_type = var.frozen.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_ingest_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = var.ingest.roles
  min = var.ingest.min
  desired = var.ingest.desired
  max = var.ingest.max
  block_devices = var.ingest.block_devices
  instance_type = var.ingest.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_coordinator_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = var.coordinator.roles
  min = var.coordinator.min
  desired = var.coordinator.desired
  max = var.coordinator.max
  block_devices = var.coordinator.block_devices
  instance_type = var.coordinator.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_ml_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = var.ml.roles
  min = var.ml.min
  desired = var.ml.desired
  max = var.ml.max
  block_devices = var.ml.block_devices
  instance_type = var.ml.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "elasticsearch_transform_nodes" {
  source = "./modules/elasticsearch-node-type"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  roles = var.transform.roles
  min = var.transform.min
  desired = var.transform.desired
  max = var.transform.max
  block_devices = var.transform.block_devices
  instance_type = var.transform.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}

module "kibana" {
  source = "./modules/kibana"
  tags = {
    CLUSTER_NAME = var.cluster_name
    ELK_VERSION = var.elk_version
    S3_BUCKET = var.s3_bucket
  }
  min = var.kibana.min
  max = var.kibana.max
  desired = var.kibana.desired
  instance_type = var.kibana.instance_type
  depends_on = [ time_sleep.wait_for_bootstrap ]
}
