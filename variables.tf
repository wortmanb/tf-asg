variable "cluster_name" {
  type = string
}

variable "elk_version" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "bootstrap_sleep" {
  type = string
  default = "1m"
}

variable "bootstrap" {
  type = object({
    desired = number
    max = number
    })
  default = {
    max = 1
    desired = 1
  }
}

variable "master" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "master")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "r5n.2xlarge")
  })
  default = {
    min = 3
    desired = 3
    max = 3
  }
}

variable "hot" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "data_hot")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "warm" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "data_warm")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "cold" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "data_cold")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "frozen" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "data_frozen")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "content" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "data_content")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "ingest" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "ingest")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "coordinator" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "transform" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "transform")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "ml" {
  type = object ({
    min = number
    desired = number
    max = number
    roles = optional(string, "ml")
    subnets = optional(list(string))
    security_group_names = optional(list(string))
    security_group_ids = optional(list(string))
    has_load_balancer = optional(bool, false)
    block_devices = optional(list(object({
      name = string
      size = number
      type = string
      purpose = string
      delete_on_termination = bool
    })),
      [{
        name = "/dev/xvda"
        size = 200
        purpose = "system"
        type = "gp2"
        delete_on_termination = true
      }]
    )
    instance_type = optional(string, "i3en.2xlarge")
  })
  default = {
    min = 0
    desired = 0
    max = 0
  }
}

variable "kibana" {
  type = object ({
    min = number
    desired = number
    max = number
    instance_type = optional(string, "r5n.2xlarge")
    })
}
