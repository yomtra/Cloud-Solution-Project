terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_launch_template" "main" {
  name_prefix   = var.launch_template.prefix
  image_id      = var.launch_template.ami
  instance_type = var.launch_template.instance_class
  tags = var.tags
}

resource "aws_autoscaling_group" "main" {
  availability_zones = var.scaling_group.availability_zones
  desired_capacity   = var.scaling_group.desired_capacity
  max_size           = var.scaling_group.max_size
  min_size           = var.scaling_group.min_size
  launch_template {
    id = aws_launch_template.main.id
    version = "$Latest"
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}