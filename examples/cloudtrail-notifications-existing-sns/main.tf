module "aws_cloud_events" {
  source = "../.."

  cloudtrail_arn        = "<CLOUDTRAIL_ARN>"
  cloudtrail_bucket_arn = "<CLOUDTRAIL_BUCKET_ARN>"
  cloudtrail_kms_arn    = "<CLOUDTRAIL_KMS_ARN>"

  sns_topic_arn                = "<EXISTING_SNS_TOPIC_ARN>"
  sns_topic_encryption_enabled = false

  wiz_access_role_arn = "<WIZ_ACCESS_ROLE_ARN>"
}
