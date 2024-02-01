output "bucket_name" {
  value = local.cloudtrail_bucket_name
}

output "bucket_account" {
  value = data.aws_caller_identity.current.account_id
}

output "sns_topic_arn" {
  value = local.sns_topic_arn
}

output "sns_topic_key_arn" {
  value = local.sns_topic_key_arn
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.wiz-cloud-events.arn
}

output "sqs_queue_key_arn" {
  value = local.sqs_queue_key_arn
}
