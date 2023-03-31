# Send logs in cloudwatch
data "aws_iam_policy_document" "send_logs_from_fluent_bit_to_cloudwatch_document" {
  count = (local.cloudwatch_enabled ? 1 : 0)
  statement {
    sid = "SendLogsFromFluentBitToCloudWatch"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}:*"
    ]
  }
}

resource "aws_iam_policy" "send_logs_from_fluent_bit_to_cloudwatch_policy" {
  count       = (local.cloudwatch_enabled ? 1 : 0)
  name_prefix = "send-logs-from-fluent-bit-to-cloudwatch-${var.eks.cluster_id}"
  description = "Policy for allowing send logs from fluent-bit  ${var.eks.cluster_id} to cloudwatch"
  policy      = data.aws_iam_policy_document.send_logs_from_fluent_bit_to_cloudwatch_document.0.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "send_logs_from_fluent_bit_to_cloudwatch_attachment" {
  count      = (local.cloudwatch_enabled ? 1 : 0)
  policy_arn = aws_iam_policy.send_logs_from_fluent_bit_to_cloudwatch_policy.0.arn
  role       = var.eks.worker_iam_role_name
}

# Decrypt objects in S3
data "aws_iam_policy_document" "decrypt_object" {
  count      = (local.s3_enabled ? 1 : 0)
  statement {
    sid = "KMSAccess"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    resources = [
      var.monitoring.s3.arn
    ]
  }
}

resource "aws_iam_policy" "decrypt_object" {
  count      = (local.s3_enabled ? 1 : 0)
  name_prefix = "s3-logs-encrypt-decrypt-${local.suffix}"
  description = "Policy for alowing decryption of encrypted object in S3 logs"
  policy      = data.aws_iam_policy_document.decrypt_object[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "decrypt_object" {
  count      = (local.s3_enabled ? 1 : 0)
  policy_arn = aws_iam_policy.decrypt_object[0].arn
  role       = var.eks.worker_iam_role_name
}

# Write objects in S3
data "aws_iam_policy_document" "write_object" {
  count      = (local.s3_enabled ? 1 : 0)
  statement {
    sid = "WriteFromS3"
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${var.monitoring.s3.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "write_object" {
  count      = (local.s3_enabled ? 1 : 0)
  name_prefix = "s3-logs-write-${local.suffix}"
  description = "Policy for allowing read object in S3 logs"
  policy      = data.aws_iam_policy_document.write_object[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "write_object_attachment" {
  count      = (local.s3_enabled ? 1 : 0)
  policy_arn = aws_iam_policy.write_object[0].arn
  role       = var.eks.worker_iam_role_name
}