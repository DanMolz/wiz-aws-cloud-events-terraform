module "aws_cloud_events" {
  source = "../.."

  integration_type = "S3"

  cloudtrail_bucket_arn = "<CLOUDTRAIL_BUCKET_ARN>"
  cloudtrail_kms_arn    = "<CLOUDTRAIL_KMS_ARN>"

  wiz_access_role_arn = "<WIZ_ACCESS_ROLE_ARN>"
}
