resource "aws_sns_topic" "alert_sns" {
  name = "s3-upload-size-alert-sns"
}

resource "aws_sns_topic_subscription" "alert_subscription" {
  topic_arn = aws_sns_topic.alert_sns.arn
  protocol  = "email"
  endpoint  = "sc.bhuvanesh@gmail.com"  # Replace with your email address
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.alert_sns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}



data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.alert_sns.arn,
    ]
    }
   statement {
    sid    = "s3.default_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.alert_sns.arn]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    }
   statement {
    sid    = "event.default_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.alert_sns.arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    }
  }