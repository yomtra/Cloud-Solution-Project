resource "aws_sns_topic" "alarm_notifications" {
  name = "alarm-notification-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = each.value
}

#monitors the instance for network bandwidth usage less than 300 mbps
resource "aws_cloudwatch_metric_alarm" "low_network_bandwidth_alarm" {
  for_each = toset(var.web_instance_ids)

  alarm_name          = "low-bandwidth-usage-alarm-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 2250000000   
  alarm_description = "Alarm when network bandwidth is less than 300 mbps"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    InstanceId = each.value
  }
}

#monitors the instance for network bandwidth usage more than 750 mbps
resource "aws_cloudwatch_metric_alarm" "high_network_bandwidth_alarm" {
  for_each = toset(var.web_instance_ids)

  alarm_name          = "high-bandwidth-usage-alarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 5625000000 
  alarm_description = "Alarm when network bandwidth exceeds 750 mbps"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    InstanceId = each.value
  }
}

#tracks http 400 errors in the ALB
resource "aws_cloudwatch_metric_alarm" "_400_error_alarm" {
  for_each = toset(var.alb_name_ids)

  alarm_name          = "400-error-alarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  alarm_description = "Alarm when ALB receives more than 100 HTTP 400 errors"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    LoadBalancer = each.value
  }
}
#monitors for high cpu usage of the instances
resource "aws_cloudwatch_metric_alarm" "high_cpu_usage_alarm" {
  for_each = toset(var.web_instance_ids)

  alarm_name          = "high-cpu-usage-alarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75  
  alarm_description = "Alarm when CPU exceeds 75%"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    InstanceId = each.value
  }
}
#monitors for low cpu usage of the instances
resource "aws_cloudwatch_metric_alarm" "low_cpu_usage_alarm" {
  for_each = toset(var.web_instance_ids)

  alarm_name          = "low-cpu-usage-alarm-${each.key}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30   
  alarm_description = "Alarm when CPU is below 30%"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    InstanceId = each.value
  }
}


