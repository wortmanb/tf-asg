variable "tags" {
  type = map(string)
}

variable "roles" {
  type = string
  description = "Roles for these nodes"
}

variable "desired" {
  type = string
  description = "Desired ASG capacity"
}

variable "min" {
  type = string
  description = "ASG min capacity"
}

variable "max" {
  type = string
  description = "ASG max capacity"
}

variable "instance_type" {
  type = string
  description = "Instance type"
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
  default = [{
    name = "/dev/xvda"
    size = 200
    type = "gp2"
    delete_on_termination = true
  }]
}