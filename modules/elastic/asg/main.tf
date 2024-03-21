resource "aws_launch_template" "elastic-lt" {
  name = "${var.tags.CLUSTER_NAME}-elastic-${var.asg-specific-tags.NODE_ROLES}-lt"
  instance_type = var.instance_type
  image_id = var.ami_id

  key_name = var.key_pair

  vpc_security_group_ids = var.vpc_security_group_ids

  metadata_options { 
    http_endpoint = "enabled"
    http_tokens = "optional"
  }

  update_defeault_version = true

  block_device_mappings {
    for_each = var.block_devices
    content {
      device_name = block_device_mappings.value["name"]
      ebs {
        volume_size           = block_device_mappings.value["size"]
        volume_type           = block_device_mappings.value["type"]
        delete_on_termination = block_device_mappings.value["delete_on_termination"]
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      var.asg-specific-tags,
      {
        "Name" = "${var.tags.CLUSTER_NAME}-${var.asg-specific-tags.NODE_ROLES}"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      var.asg-specific-tags
    )
  }

  user_data = base64encode(var.user_data_scripts)

  iam_instance_profile {
    name = "my-instance-profile"
  }
}

resource "aws_autoscaling_group" "elastic-asg" {
  name_prefix = "${var.tags.CLUSTER_NAME}-${var.asg-specific-tags.NODE_ROLES}-asg-"
  launch_template {
    name = aws_launch_template.elastic-lt.name
    version = aws_launch_template.elastic-lt.latest_version
  }
  min_size = var.minimum_capacity
  max_size = var.maximum_capacity
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.subnets
  termination_policies = ["Default"]
  lifecycle {
    create_before_destroy = true
  }
}
