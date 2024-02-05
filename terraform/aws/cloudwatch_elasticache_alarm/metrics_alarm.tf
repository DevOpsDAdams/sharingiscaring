resource "aws_cloudwatch_metric_alarm" "redis" {
  for_each                  = data.terraform_data.cw_script.result
  alarm_name                = "${each.value}-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 100
  period                    = 300
  alarm_description         = "The number of connections is at or higher than 100"
  insufficient_data_actions = []
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.sns.arn]
  ok_actions          = [aws_sns_topic.sns.arn]
  dimensions = {
    CacheClusterId = each.value
  }
}
