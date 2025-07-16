terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

# Random suffix for S3 bucket naming to ensure global uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "vpc" {
  source           = "./modules/vpc"
  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  web_subnet_cidrs = var.web_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
}
module "s3_bucket" {
  source = "./modules/s3"

  bucket_name        = "${var.bucket_name}-${random_id.bucket_suffix.hex}"
  allowed_principals = [] # Empty for secure default - no public access
  tags               = var.common_tags
}
module "application_load_balancer" {
  source = "./modules/alb"

  alb_name              = var.alb_name
  vpc_id                = module.vpc.vpc_id
  security_groups       = [aws_security_group.alb_sg.id]
  subnets               = module.vpc.web_subnet_ids 
  target_group_port     = 80
  target_group_protocol = "HTTP"
  listener_port         = 80
  listener_protocol     = "HTTP"
  health_check_path     = "/"
  health_check_matcher  = "200"

  tags = var.common_tags
}

# ADDED: Auto Scaling Group integrated with ALB
module "auto_scaling_group" {
  source = "./modules/auto_scaling"

  region = var.aws_region
  
  launch_template = {
    ami                 = "ami-0d53d72369335a9d6"  # Amazon Linux 2023 in us-west-1
    prefix              = "${var.project}-${var.environment}"
    instance_class      = "t3.micro"
    description         = "Launch template for ${var.project} web servers"
    detailed_monitoring = false
    key_name           = null  # Add key pair name if needed
    security_group_id  = aws_security_group.alb_sg.id  # Reuse ALB security group
    user_data          = base64encode(<<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Hello from ${var.project}!</h1>" > /var/www/html/index.html
      EOF
    )
  }

  scaling_group = {
    subnet_ids       = module.vpc.app_subnet_ids  # Deploy in private subnets
    desired_capacity = 2
    max_size         = 4
    min_size         = 1
  }

  scaling_policies = {
    scale_up = {
      name               = "scale-up"
      scaling_adjustment = 1
      adjustment_type    = "ChangeInCapacity"
      cooldown          = 300
    }
    scale_down = {
      name               = "scale-down"
      scaling_adjustment = -1
      adjustment_type    = "ChangeInCapacity"
      cooldown          = 300
    }
  }

  cloudwatch_alarms = {
    high_cpu = {
      name                = "high-cpu-alarm"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      period             = 300
      statistic          = "Average"
      threshold          = 75
      alarm_description  = "High CPU utilization"
      policy_to_use      = "scale_up"
    }
    low_cpu = {
      name                = "low-cpu-alarm"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      period             = 300
      statistic          = "Average"
      threshold          = 25
      alarm_description  = "Low CPU utilization"
      policy_to_use      = "scale_down"
    }
  }

  # Connect to ALB target group
  attach_to_lb = true
  lb_arn       = module.application_load_balancer.target_group_arn

  tags = var.common_tags
}

# ADDED: CloudWatch monitoring module (built by Artyom)- integrated with ALB and ASG
module "cloudwatch_monitoring" {
  source = "./modules/cloudwatch"

  # Email for alarm notifications
  notification_email = var.notification_email
  
  # Connect to ALB for HTTP error monitoring
  alb_name_id = module.application_load_balancer.alb_arn
  
  # Instance monitoring is handled by Auto Scaling Group policies
  # web_instance_id uses default placeholder value
  
  # Dependencies to ensure ALB is created first
  depends_on = [
    module.application_load_balancer,
    module.auto_scaling_group
  ]
}

# IMPROVEMENT: Comment out instance-specific alarms since we're using Auto Scaling
# The Auto Scaling module already has CPU-based alarms that work with ASG
# Artyoms's CloudWatch module has great ALB monitoring that we'll keep active