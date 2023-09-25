resource "aws_sns_topic"                "pagerduty" {
    name                                = "pagerduty-alerts"
    tags                                = {}
}

resource "aws_sns_topic_subscription"   "pagerduty" {
    protocol                            = "https"
    endpoint                            = var.pager_duty_integration_url
    topic_arn                           = aws_sns_topic.pagerduty.arn
}

resource "aws_sns_topic"                "alerts" {
    name                                = "slack_chatbot_support_info"
    tags                                = {}
}


resource "aws_sns_topic_subscription"   "alerts" {
    protocol                            = "https"
    endpoint                            = var.slack_chatbot_support_info_url
    topic_arn                           = aws_sns_topic.alerts.arn
}
