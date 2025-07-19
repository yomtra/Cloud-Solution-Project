module "vpc" {
  source           = "./modules/vpc"
  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  web_subnet_cidrs = var.web_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
}# main.tf (root)
module "iam" {
  source = "./modules/iam"
}

output "iam_ec2_instance_profile" {
  value = module.iam.ec2_instance_profile_name

}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  notification_emails = [] 
  web_instance_ids = [] 
  alb_name_ids = [] 
}

module "rds" {
  source              = "./modules/rds_module"
  name                = var.name
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  allocated_storage   = var.allocated_storage
  username            = var.username
  password            = var.password
  db_subnet_ids       = module.vpc.db_subnet_ids
  vpc_id              = module.vpc.vpc_id
  environment         = var.environment
  project             = var.project
  tags                = var.tags
}


module "web_tier_scaling_group" {
  source = "./modules/auto_scaling"
  launch_template = {
    ami = "ami-061ad72bc140532fd" 
    prefix = "capstone"
    instance_class = "t2.micro"
    security_group_id = aws_security_group.web_tier_sg.id #Replace with actual security group!!
    instance_profile_arn  = aws_iam_instance_profile.ssm_instance_profile.arn
  }

  scaling_group = {
    subnet_ids = ["subnet-03de533a5b992b8ea"] #Replace with actual subnet ids!!
    desired_capacity = 1
    max_size = 3
    min_size = 1
  }
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
    },
    increase_ec2 = {
      name = "increase-ec2-alarm"
      comparison_operator       = "GreaterThanOrEqualToThreshold"
      evaluation_periods        = 2
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = 120
      statistic                 = "Average"
      threshold                 = 75
      alarm_description         = "This metric monitors ec2 cpu utilization, if it goes above 75% for 2 periods it will trigger an alarm."
      policy_to_use = "increase-ec2"
    }
  }
  tags = {
    Name = "test"
  }

  region = var.aws_region
}

module "app_tier_scaling_group" {
  source = "./modules/auto_scaling"
  launch_template = {
    ami = "ami-061ad72bc140532fd" 
    prefix = "capstone"
    instance_class = "t2.micro"
    security_group_id = aws_security_group.app_tier_sg.id #Replace with actual security group!!
    instance_profile_arn = aws_iam_instance_profile.s3_and_ssm_instance_profile.arn
  }

  scaling_group = {
    subnet_ids = ["subnet-03de533a5b992b8ea"] #Replace with actual subnet ids!!
    desired_capacity = 1
    max_size = 3
    min_size = 1
  }
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
    },
    increase_ec2 = {
      name = "increase-ec2-alarm"
      comparison_operator       = "GreaterThanOrEqualToThreshold"
      evaluation_periods        = 2
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = 120
      statistic                 = "Average"
      threshold                 = 75
      alarm_description         = "This metric monitors ec2 cpu utilization, if it goes above 75% for 2 periods it will trigger an alarm."
      policy_to_use = "increase-ec2"
    }
  }
  tags = {
    Name = "test"
  }

  region = var.aws_region
}
