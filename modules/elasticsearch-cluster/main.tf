resource "aws_s3_object" "elastic-setup-bootstrap-script" {
  bucket = var.tags.S3_BUCKET
  key = "${var.tags.CLUSTER_NAME}/scripts/elastic-setup-bootstrap.bash"
  source = "modules/elasticsearch-cluster/files/scripts/elastic-setup-bootstrap.bash"
  acl = "private"
}

resource "aws_s3_object" "elastic-setup-script" {
  bucket = var.tags.S3_BUCKET
  key = "${var.tags.CLUSTER_NAME}/scripts/elastic-setup.bash"
  source = "modules/elasticsearch-cluster/files/scripts/elastic-setup.bash"
  acl = "private"
}

resource "aws_s3_object" "elastic-reset-password" {
  bucket = var.tags.S3_BUCKET
  key = "${var.tags.CLUSTER_NAME}/scripts/elastic-reset-password.bash"
  source = "modules/elasticsearch-cluster/files/scripts/elastic-reset-password.bash"
  acl = "private"    
}

resource "aws_s3_object" "elasticsearch-yaml" {
  bucket = var.tags.S3_BUCKET
  key = "${var.tags.CLUSTER_NAME}/elasticsearch/elasticsearch.yml"
  source = "modules/elasticsearch-cluster/files/elasticsearch/elasticsearch.yml"
  acl = "private"
}
