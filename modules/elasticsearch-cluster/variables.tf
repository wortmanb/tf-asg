variable "tags" {
  type = map(string)
  default = {
    CLUSTER_NAME = "test-asg-cluster"
    ELK_VERSION  = "8.12.0"
    S3_BUCKET    = "my-awesome-s3-bucket-CHANGE-ME"
  }
}

variable "asg-specific-tags" {
  type = map(string)
}

variable "desired_capacity" {
  type = number
  default = 0
}

variable "key_pair" {
  type = string
  default = "my-default-key-pair-CHANGE-ME"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami_id" {
  type = string
  default = "my-favorite-ami-CHANGE-ME"
}

variable "subnets" {
  type = list(string)
  default = [ "subnet-1", "subnet-2", "subnet-3" ]
}

variable "security_group_names" {
  type = list(string)
  default = [ "default", "sg-name-1" ]
}

variable "security_group_ids" {
  type = list(string)
  default = [ "sg-1", "sg-2" ]
}
