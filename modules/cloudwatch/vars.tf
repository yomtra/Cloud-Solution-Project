variable "notification_email" {
    type = string
}

variable "web_instance_id" {
  type = string
  default = "i-placeholder"  # Default placeholder for Auto Scaling compatibility
}
# NOTE: This was originally for single instance monitoring
# With Auto Scaling, individual instance monitoring is handled differently

variable "alb_name_id" {
  type = string
}