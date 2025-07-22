# Generate random suffix for globally unique S3 bucket name
# Jurabek: Added to prevent bucket name conflicts
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "vpc" {
  source           = "./modules/vpc"
  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  web_subnet_cidrs = var.web_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
  # create_nat_gateway = var.enable_nat_gateway - OLD MISSING PARAMETER  
  create_nat_gateway = var.enable_nat_gateway # Jurabek: Fixed missing NAT gateway parameter for VPC module
}# main.tf (root)
module "iam" {
  source = "./modules/iam"
}

output "iam_ec2_instance_profile" {
  value = module.iam.ec2_instance_profile_name

}

module "cloudwatch" {
  source              = "./modules/cloudwatch"
  notification_emails = []
  # autoscaling_group_name = module.web_tier_scaling_group.autoscaling_group_name - OLD SINGLE VALUE
  autoscaling_group_name = [ # Jurabek: Fixed to pass both ASG names as list instead of single value
    module.web_tier_scaling_group.autoscaling_group_name,
    module.app_tier_scaling_group.autoscaling_group_name
  ]
  # alb_name_ids = [] - OLD EMPTY LIST
  alb_name_ids = [module.application_load_balancer.alb_id] # Jurabek: Added ALB ID for monitoring
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
  app_subnet_cidrs    = var.app_subnet_cidrs  # Jurabek: Added app subnet CIDRs for RDS security group
  environment         = var.environment
  project             = var.project
  region              = var.aws_region  # Jurabek: Added missing region parameter
  tags                = var.tags
}


module "web_tier_scaling_group" {
  source = "./modules/auto_scaling"
  launch_template = {
    ami                  = "ami-061ad72bc140532fd"
    prefix               = "capstone"
    instance_class       = "t2.micro"
    security_group_id    = aws_security_group.web_tier_sg.id
    instance_profile_arn = aws_iam_instance_profile.ssm_instance_profile.arn
  }

  scaling_group = {
    # subnet_ids = ["subnet-03de533a5b992b8ea"] #Replace with actual subnet ids!! - OLD CODE
    subnet_ids       = module.vpc.web_subnet_ids # Jurabek: Fixed hardcoded subnet IDs to use VPC module outputs
    desired_capacity = 1
    max_size         = 3
    min_size         = 1
  }
  scaling_policies = {
    increase-ec2 = {
      name               = "increase-ec2"
      scaling_adjustment = 1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    },
    reduce-ec2 = {
      name               = "reduce-ec2"
      scaling_adjustment = -1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    }
  }

  cloudwatch_alarms = {
    reduce_ec2 = {
      name                = "reduce-ec2-alarm"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 30
      alarm_description   = "This metric monitors ec2 cpu utilization, if it goes below 30% for 2 periods it will trigger an alarm."
      policy_to_use       = "reduce-ec2"
    },
    increase_ec2 = {
      name                = "increase-ec2-alarm"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 75
      alarm_description   = "This metric monitors ec2 cpu utilization, if it goes above 75% for 2 periods it will trigger an alarm."
      policy_to_use       = "increase-ec2"
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
    ami                  = "ami-061ad72bc140532fd"
    prefix               = "capstone"
    instance_class       = "t2.micro"
    security_group_id    = aws_security_group.app_tier_sg.id #Replace with actual security group!!
    instance_profile_arn = aws_iam_instance_profile.s3_and_ssm_instance_profile.arn
  }

  scaling_group = {
    # subnet_ids = ["subnet-03de533a5b992b8ea"] #Replace with actual subnet ids!! - OLD CODE
    subnet_ids       = module.vpc.app_subnet_ids # Jurabek: Fixed hardcoded subnet IDs to use app tier subnets
    desired_capacity = 1
    max_size         = 3
    min_size         = 1
  }
  scaling_policies = {
    increase-ec2 = {
      name               = "increase-ec2"
      scaling_adjustment = 1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    },
    reduce-ec2 = {
      name               = "reduce-ec2"
      scaling_adjustment = -1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    }
  }

  cloudwatch_alarms = {
    reduce_ec2 = {
      name                = "reduce-ec2-alarm"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 30
      alarm_description   = "This metric monitors ec2 cpu utilization, if it goes below 30% for 2 periods it will trigger an alarm."
      policy_to_use       = "reduce-ec2"
    },
    increase_ec2 = {
      name                = "increase-ec2-alarm"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 75
      alarm_description   = "This metric monitors ec2 cpu utilization, if it goes above 75% for 2 periods it will trigger an alarm."
      policy_to_use       = "increase-ec2"
    }
  }
  tags = {
    Name = "test"
  }

  region = var.aws_region
}

# S3 Module for secure storage with KMS encryption
# Jurabek: Added S3 module for secure file storage with encryption and proper integration
module "s3_storage" {
  source = "./modules/s3"
  
  bucket_name       = "${var.project}-${var.environment}-storage-bucket-${random_id.bucket_suffix.hex}"  # Jurabek: Added random suffix to ensure unique bucket name
  environment       = var.environment
  project_name      = var.project
  enable_versioning = true
  
  # Integration with existing modules
  # allowed_iam_roles = [  # OLD CODE: Empty list caused S3 bucket policy error
  #   # Add IAM role ARNs that need access to this bucket
  # ]
  enable_bucket_policy = false  # Jurabek: Disabled bucket policy since no specific IAM roles defined yet
  allowed_iam_roles = []        # Jurabek: Keep empty for now, can be populated later with specific role ARNs
}# ALB Module for load balancing web and app tiers
# Jurabek: Added ALB module with multi-tier support and proper VPC integration
module "application_load_balancer" {
  source = "./modules/alb"

  alb_name           = "${var.project}-${var.environment}-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.web_subnet_ids
  security_group_ids = [aws_security_group.web_tier_sg.id]

  # Multi-tier configuration
  enable_app_tier        = true
  app_tier_port          = 8080
  app_tier_path_patterns = ["/api/*", "/app/*", "/backend/*"]

  # Health check configuration
  health_check_path     = "/"
  app_health_check_path = "/health"

  # Integration with S3 for access logs (optional)
  enable_access_logs = false # Set to true if you want to use S3 bucket for logs
  access_logs_bucket = module.s3_storage.bucket_id

  environment  = var.environment
  project_name = var.project
  tags         = var.tags
}

# OLD CODE - These ASG to ALB attachments were completely missing before
# Attach Auto Scaling Groups to ALB Target Groups
# Jurabek: Added ASG to ALB target group attachments for proper load balancing
resource "aws_autoscaling_attachment" "web_tier_attachment" {
  autoscaling_group_name = module.web_tier_scaling_group.autoscaling_group_name
  lb_target_group_arn    = module.application_load_balancer.web_tier_target_group_arn
}

resource "aws_autoscaling_attachment" "app_tier_attachment" {
  autoscaling_group_name = module.app_tier_scaling_group.autoscaling_group_name
  lb_target_group_arn    = module.application_load_balancer.app_tier_target_group_arn
}
