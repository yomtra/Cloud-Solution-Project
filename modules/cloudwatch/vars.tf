variable "notification_emails" {
    type = list(string)
}

variable "autoscaling_group_name" {
  type = list
}

variable "alb_name_ids" {
  type = list(string)
}