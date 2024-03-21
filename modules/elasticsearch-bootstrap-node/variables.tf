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

variable "max" {
  type = string
  description = "ASG max capacity"
}

variable "instance_type" {
  type = string
  description = "instance type"
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