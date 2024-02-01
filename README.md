<!-- BEGIN_TF_DOCS -->
# wiz-aws-cloud-events-terraform-module

A Terraform module to integrate AWS CloudTrail logs with Wiz.

Supported Configurations:

**A new SQS queue will always be created.**

- CloudTrail Notifications
  - New SNS Topic
    - CloudTrail Notification -> SNS Topic (New) -> SQS Queue
      - _CloudTrail notifications must be configured to the new SNS topic once created_
  - Existing SNS Topic
    - CloudTrail Notification -> SNS Topic (Existing) -> SQS Queue
      - _Existing CloudTrail notification SNS topic must allow subscriptions from the new SQS queue_
- S3 Bucket Notifications
  - New Bucket Notification
    - S3 Bucket Notification (New) -> SNS Topic (New) -> SQS Queue
    - S3 Bucket Notification (New) -> SQS Queue
  - Existing Bucket Notification
    - S3 Bucket Notification (Existing) -> SNS Topic (Existing) -> SQS Queue

The module also aims to encrypt all notifications in transit using AWS CMKs.
This behavior can be modified by changing the `sns_topic_encryption_enabled` and/or `sqs_encryption_enabled` variables.
Users can also "bring their own key" and provide the ARNs of their CMKs as the `sns_topic_encryption_key_arn` and/or `sqs_encryption_key_arn` variables.

In cases where CloudTrail logs are encrypted with a customer managed key, you may also need to add a statement to your KMS key policy in order for Wiz to properly decrypt the log files. An example statement for the key policy is provided below.

```json
{
  "Sid": "Allow Wiz role to decrypt CloudTrail files",
  "Effect": "Allow",
  "Principal": {
    "AWS": "<WIZ_ROLE_ARN>"
  },
  "Action": "kms:Decrypt",
  "Resource": "<CLOUDTRAIL_ENCRYPTION_KEY_ARN>",
  "Condition": {
    "Null": {
      "kms:EncryptionContext:aws:cloudtrail:arn": "false"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |
| random | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| random | >= 2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.wiz_allow_cloudtrail_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.wiz_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.wiz_access_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_kms_key.wiz_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket_notification.cloudtrail_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_sns_topic.wiz-cloud-events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.wiz-cloudtrail-logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.wiz-cloud-events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.wiz-cloud-events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [random_id.uniq](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.wiz_access_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudtrail_bucket_arn | The ARN of the S3 bucket used to store CloudTrail logs. | `string` | n/a | yes |
| wiz_access_role_arn | The ARN of the AWS role used by the Wiz cloud connector. | `string` | n/a | yes |
| cloudtrail_arn | The ARN of the CloudTrail with which to integrate. | `string` | `""` | no |
| cloudtrail_kms_arn | The ARN of the KMS key used to encrypt CloudTrail logs. | `string` | `""` | no |
| create_sns_topic_subscription | A boolean representing whether the module should attempt to create an SNS Topic subscription. | `bool` | `true` | no |
| integration_type | Specify the integration type. Can only be `CLOUDTRAIL` or `S3`. Defaults to `CLOUDTRAIL` | `string` | `"CLOUDTRAIL"` | no |
| kms_key_deletion_days | The waiting period, specified in number of days, before deleting the KMS key. | `number` | `30` | no |
| kms_key_multi_region | A boolean representing whether the KMS key is a multi-region or regional key. | `bool` | `true` | no |
| kms_key_rotation | A boolean representing whether to enable KMS automatic key rotation. | `bool` | `false` | no |
| s3_notification_log_prefix | The object prefix for which to create S3 notifications. | `string` | `""` | no |
| s3_notification_type | The destination type that should be used for S3 notifications: `SNS` or `SQS`. Defaults to `SNS` | `string` | `"SNS"` | no |
| sns_topic_arn | The ARN of an existing SNS Topic to which SQS should be subscribed. | `string` | `""` | no |
| sns_topic_encryption_enabled | Set this to `false` to disable encryption on a sns topic. Defaults to true | `bool` | `true` | no |
| sns_topic_encryption_key_arn | The ARN of an existing KMS encryption key to be used for SNS | `string` | `""` | no |
| sqs_encryption_enabled | Set this to `true` to enable server-side encryption on SQS. | `bool` | `true` | no |
| sqs_encryption_key_arn | The ARN of the KMS encryption key to be used for SQS (Required when `sqs_encryption_enabled` is `true`) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_account | n/a |
| bucket_name | n/a |
| sns_topic_arn | n/a |
| sns_topic_key_arn | n/a |
| sqs_queue_arn | n/a |
| sqs_queue_key_arn | n/a |
<!-- END_TF_DOCS -->