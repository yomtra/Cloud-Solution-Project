variable "notification_emails" {
    type = list(string)
}

variable "autoscaling_group_name" {
  type = string
}

variable "alb_name_ids" {
  type = list(string)
}