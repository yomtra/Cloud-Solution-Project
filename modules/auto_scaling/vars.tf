
variable "region" {
  type = string
}

variable "aws_launch_template" {
  type = object({
    ami            = string
    prefix         = string
    instance_class = string
  })
}

variable "scaling_group" {
  type=object({
    availability_zones = list(string)
    desired_capacity   = number
    max_size           = number
    min_size           = number
  })
}