variable "launch_template" {
  type = object({
    ami            = string
    prefix         = string
    instance_class = string
    description    = optional(string)
    detailed_monitoring = optional(bool, false)
    key_name = optional(string)
    security_group_id = optional(string)
    user_data = optional(string)
    instance_profile_arn = optional(string)
  })
}

variable "scaling_group" {
  type=object({
    subnet_ids         = optional(list(string))
    desired_capacity   = number
    max_size           = number
    min_size           = number
  })
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "scaling_policies" {
  type=map(object({
    name               = string
    scaling_adjustment = number
    adjustment_type    = string
    cooldown           = number
  }))
}

variable "attach_to_lb" {
  type = bool
  default = false
}

variable "lb_arn" {
  type = string
  default = ""
}

variable "cloudwatch_alarms" {
  type = map(object({
    name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    period = number
    statistic = string
    threshold = number
    alarm_description = string
    insufficient_data_actions = optional(list(string))
    policy_to_use = string
  }))
}