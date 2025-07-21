# ALB Module - Main Configuration
# This module creates an Application Load Balancer with target groups and listeners

# Create Application Load Balancer
resource "aws_lb" "main_alb" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets           = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  # Access logs configuration
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.alb_name
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Create Target Group for Web Tier
resource "aws_lb_target_group" "web_tier_tg" {
  name     = "${var.alb_name}-web-tg"
  port     = var.web_tier_port
  protocol = var.web_tier_protocol
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.web_tier_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Stickiness configuration
  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = var.stickiness_duration
      enabled         = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.alb_name}-web-tg"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Create Target Group for App Tier (optional)
resource "aws_lb_target_group" "app_tier_tg" {
  count = var.enable_app_tier ? 1 : 0
  
  name     = "${var.alb_name}-app-tg"
  port     = var.app_tier_port
  protocol = var.app_tier_protocol
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.app_health_check_path
    port                = "traffic-port"
    protocol            = var.app_tier_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.alb_name}-app-tg"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Create HTTP Listener (redirects to HTTPS if SSL enabled)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  # Redirect to HTTPS if SSL is enabled
  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # Forward to target group if HTTPS is not enabled
  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.web_tier_tg.arn
    }
  }

  tags = var.tags
}

# Create HTTPS Listener (only if SSL is enabled)
resource "aws_lb_listener" "https_listener" {
  count = var.enable_https ? 1 : 0
  
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tier_tg.arn
  }

  tags = var.tags
}

# Create listener rules for path-based routing (optional)
resource "aws_lb_listener_rule" "app_tier_rule" {
  count = var.enable_app_tier && var.enable_https ? 1 : 0
  
  listener_arn = aws_lb_listener.https_listener[0].arn
  priority     = var.app_tier_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_tg[0].arn
  }

  condition {
    path_pattern {
      values = var.app_tier_path_patterns
    }
  }

  tags = var.tags
}

# Create listener rules for HTTP if HTTPS is not enabled
resource "aws_lb_listener_rule" "app_tier_rule_http" {
  count = var.enable_app_tier && !var.enable_https ? 1 : 0
  
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = var.app_tier_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_tg[0].arn
  }

  condition {
    path_pattern {
      values = var.app_tier_path_patterns
    }
  }

  tags = var.tags
}
