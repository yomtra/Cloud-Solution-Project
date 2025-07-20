output "high_cpu_usage_alarm" {
  description = "arn of high cpu usage alarm"
  value = aws_cloudwatch_metric_alarm.high_cpu_usage_alarm.arn
}

output "low_cpu_usage_alarm" {
  description = "arn of low cpu usage alarm"
  value = aws_cloudwatch_metric_alarm.low_cpu_usage_alarm.arn
}

output "high_asg_network_in_alarm" {
  description = "arn of high network in alarm"
  value = aws_cloudwatch_metric_alarm.high_asg_network_in_alarm.arn
}

output "low_asg_network_out_alarm" {
  description = "arn of low asg network out alarm"
  value = aws_cloudwatch_metric_alarm.low_asg_network_out_alarm.arn
}