# Test Terraform file, to avoid scaffolding issues and just test the concept
# at hand.

resource "aws_launch_template" "bdw-test-lt" {
  name = "bdw-test-lt"
  instance_type = "t2.micro"
  image_id = "ami-02d7fd1c2af6eead0"
#  image_id = "ami-0c101f26f147fa7fd"
#  image_id = "ami-019f9b3318b7155c5"

  key_name = "bdw-test-kp"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
  }

  update_default_version = true

  # Network interface configuration
  network_interfaces {
    # Associates a public IP address with the instance
    associate_public_ip_address = true

    # Security groups to associate with the instance
    security_groups = [ aws_security_group.bdw-test-sg.id ]
  }

  tags = {
    division = "field"
    org = "delivery"
    team = "consulting"
    project = "@bret"
  }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags = merge(
  #     var.tags,
  #     var.asg_specific_tags,
  #     {
  #       "Name" = "${var.asg_specific_tags.NODE_ROLES}"
  #     }
  #   )
  # }

  # tag_specifications {
  #   resource_type = "volume"
  #   tags = merge(
  #     var.tags,
  #     var.asg_specific_tags
  #   )
  # }

  iam_instance_profile {
    name = "bdw-test-profile"
  }
}

resource "aws_autoscaling_group" "bdw-test-asg" {
  name = "bdw-test-asg"
  launch_template {
    name = aws_launch_template.bdw-test-lt.name
    version = aws_launch_template.bdw-test-lt.latest_version
  }
  min_size = 0
  max_size = 3
  desired_capacity = 3
  vpc_zone_identifier = [for net in aws_subnet.public_subnets : net.id]
  termination_policies = ["Default"]
  # lifecycle {
  #   create_before_destroy = true
  # }
  # ARN of the target group to update with current instances
  #target_group_arns = [ aws_lb_target_group.bdw-test-tg[1].arn ]
  target_group_arns = var.lb ? [ aws_lb_target_group.bdw-test-tg[0].arn ] : []
  tag {
    key = "divison"
    value = "field"
    propagate_at_launch = true
  }
  tag {
    key = "org"
    value = "delivery"
    propagate_at_launch = true
  }
  tag {
    key = "team"
    value = "consulting"
    propagate_at_launch = true
  }
  tag {
    key = "project"
    value = "@bret"
    propagate_at_launch = true
  }
}

# Create a target group for use by the LB Listener
resource "aws_lb_target_group" "bdw-test-tg" {
  count = var.lb ? 1 : 0
  name = "bdw-test-tg"
  port = 5601
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main.id
  tags = {
    division = "field"
    org = "delivery"
    team = "consulting"
    project = "@bret"
  }
}

# Create an ALB for this ASG
resource "aws_lb" "bdw-test-lb" {
  count = var.lb ? 1 : 0
  name = "bdw-test-lb"
  internal = false
  load_balancer_type = "application"
##  security_groups = var.vpc_security_group_ids
  subnets = [for net in aws_subnet.public_subnets : net.id]

  enable_deletion_protection = false
  tags = {
    division = "field"
    org = "delivery"
    team = "consulting"
    project = "@bret"
  }
}

# Create a LB Listener which knows about the TG and link it to the LB
resource "aws_lb_listener" "bdw-test-lb-listener" {
  count = var.lb ? 1 : 0
  load_balancer_arn = aws_lb.bdw-test-lb[count.index].arn
  port = 5601
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.bdw-test-tg[count.index].arn
  }
  tags = {
    division = "field"
    org = "delivery"
    team = "consulting"
    project = "@bret"
  }
}


