This module creates a single auto scaling group that uses SimpleScaling and a launch template. 
Ex:
```

  launch_template = {
    ami = "ami-061ad72bc140532fd" 
    prefix = "capstone"
    instance_class = "t2.micro"
    security_group_id = "sg-016476a2309bc0e3b"
  }

  ```
```

  scaling_group = {
    availability_zones = ["us-west-1a", "us-west-1c"]
    desired_capacity = 1
    max_size = 3
    min_size = 1
  }

  ```
```

  The module also takes a list of scaling policies
  Ex:

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
Ex:

```

variable "cloudwatch_alarms" {
  type = map(object({
    name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    period = number
    statistic = string
    threshold = number
    alarm_description = string
    insufficient_data_actions = optional(list(string))
    policy_to_use = string
  }))
}

```

The scaling group can be attached to an load balancer by setting the variable "attach_to_lb" to true, and then setting "lb_arn" to the ARN of the load balancer.
The module must also be given a region.