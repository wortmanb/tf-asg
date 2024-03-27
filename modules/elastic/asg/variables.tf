variable "tags" {
  type = map(string)
  default = {
    CLUSTER_NAME = "test-asg-cluster"
    ELK_VERSION = "8.12.0"
    S3_BUCKET = "my-s3-bucket-CHANGE-ME"
  }
}

variable "asg-specific-tags" {
  type = map(string)
  default = {
    NODE_ROLES = "DEFINE-ME"
    BOOTSTRAP = false
  }
}

variable "desired_capacity" {
  type = number
  default = 0
}

variable "minimum_capacity" {
  type = number
  default = 0
}

variable "maximum_capacity" {
  type = number
  default = 0
}

variable "key_pair" {
  type = string
  default = "my-default-keypair"
}

variable "instance_type" {
  type = string
  default = "my-favorite-instance-type"
}

variable "ami_id" {
  type = string
  default = "my-favorite-ami"
}

variable "install_type" {
  type = string
  default = "elastic"
}

variable "subnets" {
  type = list(string)
  default = [ "subnet-1", "subnet-2", "subnet-3" ]
}

variable "security_group_names" {
  type = list(string)
  default = [ "default", "security-group-name-1" ]
}

variable "security_group_ids" {
  type = list(string)
  default = [ "sg-1", "sg-2" ]
}

variable "user_data_script" {
  type = string
}

variable "has_load_balancer" {
  type = bool
  default = false
}

variable "block_devices" {
  type = list(object([
    name = string
    size = number
    type = string
    delete_on_termination = bool
  ]))
}

















