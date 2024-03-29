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
  default = "elastic"
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

variable "user_data_script" {
  type = string
}

variable "has_load_balancer" {
  type = bool
  default = false
}

variable "block_devices" {
  type = list(object({
      name = string
      size = number
      type = string
      delete_on_termination = bool
    }))
}

















