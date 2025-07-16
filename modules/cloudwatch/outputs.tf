output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alarm_notifications.arn
}

output "alarm_notification_topic_name" {
  description = "Name of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alarm_notifications.name
}