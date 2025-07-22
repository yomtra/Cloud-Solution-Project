terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

resource "aws_launch_template" "main" {
  name_prefix   =          var.launch_template.prefix
  image_id               = var.launch_template.ami
  instance_type          = var.launch_template.instance_class
  description            = var.launch_template.description
  tags                   = var.tags
  key_name               = var.launch_template.key_name
  user_data              = var.launch_template.user_data
  vpc_security_group_ids = [var.launch_template.security_group_id]

  iam_instance_profile {
    arn = var.launch_template.instance_profile_arn
  }

  monitoring {
    enabled = var.launch_template.detailed_monitoring
  }
}

resource "aws_autoscaling_group" "main" {
  vpc_zone_identifier = var.scaling_group.subnet_ids
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
  target_group_arns = var.attach_to_lb ? [var.lb_arn] : [""]
}

resource "aws_autoscaling_policy" "policies" {
    for_each = var.scaling_policies
    name                   = each.value.name
    scaling_adjustment     = each.value.scaling_adjustment
    adjustment_type        = each.value.adjustment_type
    cooldown               = each.value.cooldown
    autoscaling_group_name = aws_autoscaling_group.main.name
    policy_type = "SimpleScaling"
}

# Attach the Auto Scaling Group to the ALB target group
resource "aws_autoscaling_attachment" "my_asg_attachment" {
  count = var.attach_to_lb ? 1 : 0
    autoscaling_group_name = aws_autoscaling_group.main.name
    lb_target_group_arn = var.lb_arn
}

resource "aws_cloudwatch_metric_alarm" "reduce_ec2_alarm" {
  for_each = var.cloudwatch_alarms
  alarm_name                = each.value.name
  comparison_operator       = each.value.comparison_operator
  evaluation_periods        = each.value.evaluation_periods
  metric_name               = each.value.metric_name
  namespace                 = "AWS/EC2"
  period                    = each.value.period
  statistic                 = each.value.statistic
  threshold                 = each.value.threshold
  alarm_description         = each.value.alarm_description
  insufficient_data_actions = []

  alarm_actions = ["${aws_autoscaling_policy.policies[each.value.policy_to_use].arn}"]
}