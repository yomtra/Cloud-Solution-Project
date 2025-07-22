This module creates a single auto scaling group that uses SimpleScaling and a launch template. 
Ex:
# CloudWatch Alarm Module

This module creates a single scaling group and launch instance that use Simple Scaling, as well as related resources.

## Resources

- `aws_launch_template` – Launch template that will be used by the scaling group
- `aws_autoscaling_group` – Auto scaling group
- `aws_autoscaling_policy` – SimpleScaling policy that can cause scaling up or down

Example launch templates and policies
```

  launch_template = {
    ami = "ami-061ad72bc140532fd" 
    prefix = "capstone"
    instance_class = "t2.micro"
    security_group_id = "sg-016476a2309bc0e3b"
  }

  scaling_group = {
    availability_zones = ["us-west-1a", "us-west-1c"]
    desired_capacity = 1
    max_size = 3
    min_size = 1
  }

  ```

```

    scaling_policies = {
    increase-ec2 = {
    name                   = "increase-ec2"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    },
    reduce-ec2 = {
    name                   = "reduce-ec2"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    }
  }

  ```

These policies must be activated by Cloudwatch alarms, with each alarm having a "policy_to_use" attribute that must be set to the name of one of the scaling policies

```
cloudwatch_alarms = {
    reduce_ec2 = {
      name = "reduce-ec2-alarm"
      comparison_operator       = "LessThanOrEqualToThreshold"
      evaluation_periods        = 2
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = 120
      statistic                 = "Average"
      threshold                 = 30
      alarm_description         = "This metric monitors ec2 cpu utilization, if it goes below 30% for 2 periods it will trigger an alarm."
      policy_to_use = "reduce-ec2"
    }
}

```

The scaling group can be attached to an load balancer by setting the variable "attach_to_lb" to true, and then setting "lb_arn" to the ARN of the load balancer.
The module must also be given a region.
