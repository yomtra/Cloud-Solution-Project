resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}
# Purpose: Creates the main Application Load Balancer for distributing incoming traffic
# Usage: Internet-facing ALB that receives traffic from users and routes to backend servers
# Configuration: Deployed across multiple public subnets for high availability
# Security: Protected by security groups that control allowed inbound traffic
# Flexibility: Deletion protection disabled for development/testing environments
# Best Practice: Application-type load balancer supports HTTP/HTTPS and advanced routing

resource "aws_lb_target_group" "this" {
  name     = "${var.alb_name}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = var.health_check_matcher
  }

  tags = var.tags
}
# Purpose: Defines a group of backend servers that will receive traffic from the load balancer
# Usage: ALB routes traffic to healthy targets in this group based on health check results
# Health Monitoring: Checks /health endpoint every 30 seconds with 5-second timeout
# Failover Logic: 5 consecutive healthy checks to mark healthy, 2 unhealthy to mark unhealthy
# Protocol: HTTP on port 80 for web application traffic
# Integration: Must be in same VPC as the load balancer for internal communication
# Best Practice: Health checks ensure only healthy servers receive traffic

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = var.enable_https_redirect && var.enable_https ? "redirect" : "forward"
    
    dynamic "redirect" {
      for_each = var.enable_https_redirect && var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    
    target_group_arn = var.enable_https_redirect && var.enable_https ? null : aws_lb_target_group.this.arn
  }
}
# Purpose: Defines how the load balancer listens for incoming traffic and routes it
# Usage: Listens on port 80 for HTTP traffic
# Conditional Routing: Can redirect to HTTPS or forward to target group
# Security: Automatic HTTPS redirect ensures encrypted traffic
# Traffic Flow: Internet -> ALB Listener -> HTTPS Redirect OR Target Group
# Protocol: HTTP for web traffic with optional HTTPS upgrade
# Integration: Links the load balancer to target group for complete traffic path
# Best Practice: Flexible configuration supports both HTTP-only and HTTPS-redirect scenarios

resource "aws_lb_listener" "https_frontend" {
  count             = var.enable_https && var.ssl_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
# Purpose: Creates HTTPS listener for encrypted traffic on port 443
# Security: Terminates SSL/TLS encryption at the load balancer
# Conditional: Only created when HTTPS is enabled and certificate is provided
# SSL Policy: Uses secure TLS 1.2 policy for modern browser compatibility
# Performance: SSL termination reduces backend server CPU usage
# Best Practice: Essential for applications handling sensitive data
# Integration: Works alongside HTTP listener for mixed traffic scenarios