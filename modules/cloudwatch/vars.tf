variable "notification_emails" {
    type = list(string)
}

variable "autoscaling_group_name" {
  type = list(string)  # Jurabek: Changed from list to list(string) for proper type definition
  description = "List of Auto Scaling Group names to monitor"
}

variable "alb_name_ids" {
  type = list(string)
}