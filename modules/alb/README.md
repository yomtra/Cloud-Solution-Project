# ALB Module

This Terraform module creates an AWS Application Load Balancer (ALB) with target groups, listeners, and configurable routing rules.

## Features

- Application Load Balancer: Internet-facing or internal ALB
- Target Groups: Web tier and optional app tier target groups
- Health Checks: Configurable health check settings
- HTTPS Support: Optional SSL/TLS termination
- Path-based Routing: Route traffic based on URL patterns
- Session Stickiness: Optional session persistence
- Access Logs: Optional ALB access logging to S3
- Security: Configurable security groups and deletion protection
- Monitoring: CloudWatch metrics integration

## Architecture

```
Internet/VPC
     │
     ▼
┌─────────────┐
│     ALB     │ ← Security Groups
│ (Multi-AZ)  │ ← Subnets (≥2 AZs)
└─────────────┘
     │
     ├── HTTP Listener (Port 80)
     │   └── Redirect to HTTPS (if enabled)
     │
     └── HTTPS Listener (Port 443) [optional]
         ├── Default: Web Tier Target Group
         └── Rules: App Tier Target Group (path-based)
```

## Usage

### Basic Usage - HTTP Only

```hcl
module "alb" {
  source = "./modules/alb"

  alb_name           = "my-application-lb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb_sg.id]
  
  environment  = "prod"
  project_name = "my-project"
}
```

### Advanced Usage - HTTPS with App Tier

```hcl
module "alb" {
  source = "./modules/alb"

  alb_name           = "my-secure-lb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb_sg.id]
  
  # HTTPS Configuration
  enable_https    = true
  certificate_arn = "arn:aws:acm:region:account:certificate/certificate-id"
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  
  # Multi-tier setup
  enable_app_tier         = true
  app_tier_port          = 8080
  app_tier_path_patterns = ["/api/*", "/backend/*"]
  
  # Health checks
  health_check_path               = "/health"
  app_health_check_path          = "/api/health"
  health_check_healthy_threshold  = 3
  health_check_interval          = 30
  
  # Access logs
  enable_access_logs = true
  access_logs_bucket = module.s3_storage.bucket_id
  access_logs_prefix = "alb-logs"
  
  # Security
  enable_deletion_protection = true
  
  environment  = "prod"
  project_name = "my-project"
  
  tags = {
    Team = "DevOps"
    Cost = "Engineering"
  }
}
```

### Integration with Auto Scaling Groups

```hcl
# Auto Scaling Group attachment to target groups
resource "aws_autoscaling_attachment" "web_tier" {
  autoscaling_group_name = module.web_tier_asg.autoscaling_group_id
  lb_target_group_arn   = module.alb.web_tier_target_group_arn
}

resource "aws_autoscaling_attachment" "app_tier" {
  count = var.enable_app_tier ? 1 : 0
  
  autoscaling_group_name = module.app_tier_asg.autoscaling_group_id
  lb_target_group_arn   = module.alb.app_tier_target_group_arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb_name | Name of the Application Load Balancer | `string` | n/a | yes |
| security_group_ids | List of security group IDs to assign to the ALB | `list(string)` | n/a | yes |
| subnet_ids | List of subnet IDs where the ALB will be deployed | `list(string)` | n/a | yes |
| vpc_id | VPC ID where the ALB and target groups will be created | `string` | n/a | yes |
| internal | Whether the load balancer is internal or internet-facing | `bool` | `false` | no |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| project_name | Name of the project for tagging purposes | `string` | `"cloud-solution-project"` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| enable_deletion_protection | Enable deletion protection for the ALB | `bool` | `false` | no |
| enable_access_logs | Enable access logs for the ALB | `bool` | `false` | no |
| access_logs_bucket | S3 bucket name for ALB access logs | `string` | `""` | no |
| web_tier_port | Port for the web tier target group | `number` | `80` | no |
| web_tier_protocol | Protocol for the web tier target group | `string` | `"HTTP"` | no |
| enable_app_tier | Enable app tier target group and routing | `bool` | `false` | no |
| app_tier_port | Port for the app tier target group | `number` | `8080` | no |
| app_tier_protocol | Protocol for the app tier target group | `string` | `"HTTP"` | no |
| health_check_path | Health check path for web tier | `string` | `"/"` | no |
| app_health_check_path | Health check path for app tier | `string` | `"/health"` | no |
| enable_https | Enable HTTPS listener | `bool` | `false` | no |
| certificate_arn | ARN of the SSL certificate for HTTPS listener | `string` | `""` | no |
| enable_stickiness | Enable session stickiness | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | The DNS name of the Application Load Balancer |
| alb_arn | The ARN of the Application Load Balancer |
| alb_zone_id | The canonical hosted zone ID of the Application Load Balancer |
| web_tier_target_group_arn | The ARN of the web tier target group |
| app_tier_target_group_arn | The ARN of the app tier target group (if enabled) |
| target_group_arns | ARNs of all target groups created by this module |

## Security Considerations

- Security Groups: Configure appropriate security groups for the ALB
- HTTPS: Use HTTPS listeners for production environments
- Access Logs: Enable access logs for monitoring and compliance
- Health Checks: Configure appropriate health check endpoints
- Deletion Protection: Enable for production environments

## Monitoring

The module provides several outputs that can be used with CloudWatch:
- ALB metrics via `alb_arn_suffix`
- Target group metrics via `*_target_group_arn_suffix`

## Author

Created as part of the Cloud Solution Project group collaboration.
