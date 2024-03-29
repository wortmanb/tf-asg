resource "aws_launch_template" "elastic-lt" {
  name          = "${var.tags.CLUSTER_NAME}-elastic-${var.asg-specific-tags.NODE_ROLES}-lt"
  instance_type = var.instance_type
  image_id      = var.ami_id

  key_name = var.key_pair

  vpc_security_group_ids = var.security_group_ids

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional" # you can set it to "required" or "optional"
  }

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 200
      volume_type           = "gp2"
      delete_on_termination = true
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

  user_data = base64encode(var.user_data_script)

  iam_instance_profile {
    name = "bdw-test-profile"
  }
}

# Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "elastic-asg" {
  name_prefix = "${var.tags.CLUSTER_NAME}-${var.asg-specific-tags.NODE_ROLES}-asg-"
  launch_template {
    name = aws_launch_template.elastic-lt.name
    version = aws_launch_template.elastic-lt.latest_version
  }
  min_size = var.min
  max_size = var.max
  desired_capacity = var.desired
  vpc_zone_identifier = var.subnets
  termination_policies = ["Default"]
  lifecycle {
    create_before_destroy = true
  }
}
