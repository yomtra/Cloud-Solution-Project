# Jurabek: Updated outputs to handle count-based resources instead of for_each
output "high_cpu_usage_alarm_arns" {
  description = "List of high cpu usage alarm ARNs"
  value = aws_cloudwatch_metric_alarm.high_cpu_usage_alarm[*].arn
}

output "low_cpu_usage_alarm_arns" {
  description = "List of low cpu usage alarm ARNs"
  value = aws_cloudwatch_metric_alarm.low_cpu_usage_alarm[*].arn
}

output "high_asg_network_in_alarm_arns" {
  description = "List of high network in alarm ARNs"
  value = aws_cloudwatch_metric_alarm.high_asg_network_in_alarm[*].arn
}

output "low_asg_network_out_alarm_arns" {
  description = "List of low asg network out alarm ARNs"
  value = aws_cloudwatch_metric_alarm.low_asg_network_out_alarm[*].arn
}

output "alb_400_error_alarm_arns" {
  description = "List of ALB 400 error alarm ARNs"
  # value = aws_cloudwatch_metric_alarm._400_error_alarm[*].arn  # OLD CODE: Invalid resource reference
  value = aws_cloudwatch_metric_alarm.alb_400_error_alarm[*].arn  # Jurabek: Updated to match new resource name
}