provider "aws" {
  region = "eu-west-2"  # Set your desired AWS region
}

resource "aws_s3_bucket" "example_bucket" {
  count = "${length(var.existing_s3_bucket_name)}"
  bucket      = var.existing_s3_bucket_name[count.index]
  # Add other S3 bucket configurations as needed
}

/*
data "aws_s3_bucket" "bucket" {
  count = "${length(var.existing_s3_bucket_name)}"
  bucket = var.existing_s3_bucket_name[count.index]
}
*/

resource "aws_s3_bucket_notification" "MyS3BucketNotification" {
  count = "${length(var.existing_s3_bucket_name)}"
  bucket      = var.existing_s3_bucket_name[count.index]
  eventbridge = true
}


resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  count = "${length(var.existing_s3_bucket_name)}"
  
  name                = "s3-upload-size-rule-${element(var.existing_s3_bucket_name, count.index)}"
  description         = "Detect S3 uploads larger than 1GB"
  event_pattern       = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created", "Put Object"],
  "detail": {
    "bucket": {
      "name": ["${element(var.existing_s3_bucket_name, count.index)}"]
    },
    "object": {
      "size": [{
        "numeric": [">", 1000000]
      }]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "s3_event_target" {
  count = "${length(var.existing_s3_bucket_name)}"

  rule      = aws_cloudwatch_event_rule.s3_event_rule[count.index].name
  arn       = aws_sns_topic.alert_sns.arn
  target_id = "s3-event-target-${element(var.existing_s3_bucket_name, count.index)}"
}


