module "vpc" {
  source           = "./modules/vpc"
  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  web_subnet_cidrs = var.web_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
}

module "iam" {
  source = "./modules/iam"
}

#Required to allow the cloudwatch module to know the name of the ALB before applying
locals {
  alb_name = "${var.project}-${var.environment}-alb"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  notification_emails = ["example@example.com"]
  alb_name_ids = [local.alb_name]
  autoscaling_group_name = module.web_tier_scaling_group.autoscaling_group_name
  depends_on = [ module.app_tier_scaling_group ]
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
    ami = var.ami
    prefix = var.project
    instance_class = "t2.micro"
    security_group_id = aws_security_group.web_tier_sg.id 
    instance_profile_arn  = aws_iam_instance_profile.ssm_instance_profile.arn
  }

  scaling_group = {
    subnet_ids = module.vpc.web_subnet_ids
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
  tags = var.tags

  depends_on = [ module.vpc ]
}

module "app_tier_scaling_group" {
  source = "./modules/auto_scaling"
  launch_template = {
    ami = var.ami
    prefix = var.project
    instance_class = "t2.micro"
    security_group_id = aws_security_group.app_tier_sg.id 
    instance_profile_arn = aws_iam_instance_profile.s3_and_ssm_instance_profile.arn
  }

  scaling_group = {
    subnet_ids = module.vpc.app_subnet_ids
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
  tags = var.tags
  
  depends_on = [ module.vpc ]
}

# Data source to get current AWS account ID


# S3 Module for secure storage with KMS encryption
module "s3_storage" {
  source = "./modules/s3"
  
  bucket_name       = "${var.project}-${var.environment}-storage-bucket123123"
  environment       = var.environment
  project_name      = var.project
  enable_versioning = true
  root_user_arn     = module.iam.sysadmin1_arn
  enable_bucket_policy = false
  
  # Integration with existing modules
  allowed_iam_roles = [
  module.iam.sysadmin2_arn
  ]
}


# ALB Module for load balancing web and app tiers
module "application_load_balancer" {
  source = "./modules/alb"
  
  alb_name           = local.alb_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.web_subnet_ids
  security_group_ids = [aws_security_group.web_tier_sg.id]
  
  # Multi-tier configuration
  enable_app_tier         = true
  app_tier_port          = 8080
  app_tier_path_patterns = ["/api/*", "/app/*", "/backend/*"]
  
  # Health check configuration
  health_check_path     = "/"
  app_health_check_path = "/health"
  
  # Integration with S3 for access logs (optional)
  enable_access_logs = false  # Set to true if you want to use S3 bucket for logs
  access_logs_bucket = module.s3_storage.bucket_id
  
  environment  = var.environment
  project_name = var.project
  tags         = var.tags
}
