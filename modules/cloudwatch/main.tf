resource "aws_sns_topic" "alarm_notifications" {
  name = "alarm-notification-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = each.value
}

#monitors average network out for asg 750
resource "aws_cloudwatch_metric_alarm" "low_asg_network_out_alarm" {
  count = length(var.autoscaling_group_name)  # Jurabek: Changed to count to avoid dependency issues
  
  alarm_name          = "low-asg-network-out-alarm-${count.index}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupOut"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 2250000000   
  alarm_description = "Alarm when network bandwidth is less than 300 mbps for ${var.autoscaling_group_name[count.index]}"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name[count.index]
  }
}

#monitors average network in for asg 300
resource "aws_cloudwatch_metric_alarm" "high_asg_network_in_alarm" {
  count = length(var.autoscaling_group_name)  # Jurabek: Changed to count to avoid dependency issues
  
  alarm_name          = "high-asg-network-in-alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupIn"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 5625000000 
  alarm_description = "Alarm when network bandwidth exceeds 750 mbps for ${var.autoscaling_group_name[count.index]}"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name[count.index]
  }
}

#tracks http 400 errors in the ALB
# resource "aws_cloudwatch_metric_alarm" "_400_error_alarm" {  # OLD CODE: Invalid name starting with underscore and number
resource "aws_cloudwatch_metric_alarm" "alb_400_error_alarm" {  # Jurabek: Fixed resource name - can't start with underscore/number
  count = length(var.alb_name_ids)  # Jurabek: Changed to count to avoid dependency issues

  alarm_name          = "400-error-alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  alarm_description = "Alarm when ALB receives more than 100 HTTP 400 errors for ${var.alb_name_ids[count.index]}"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    LoadBalancer = var.alb_name_ids[count.index]
  }
}
#monitors for high cpu usage of the asg
resource "aws_cloudwatch_metric_alarm" "high_cpu_usage_alarm" {
  count = length(var.autoscaling_group_name)  # Jurabek: Changed to count to avoid dependency issues
  
  alarm_name          = "high-cpu-usage-alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupAverageCPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 75  
  alarm_description = "Alarm when CPU exceeds 75% for ${var.autoscaling_group_name[count.index]}"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name[count.index]
  }
}
#monitors for low cpu usage of the asg
resource "aws_cloudwatch_metric_alarm" "low_cpu_usage_alarm" {
  count = length(var.autoscaling_group_name)  # Jurabek: Changed to count to avoid dependency issues
  
  alarm_name          = "low-cpu-usage-alarm-${count.index}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupAverageCPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 30   
  alarm_description = "Alarm when CPU is below 30% for ${var.autoscaling_group_name[count.index]}"
  insufficient_data_actions = []
  alarm_actions     = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name[count.index]
  }
}


