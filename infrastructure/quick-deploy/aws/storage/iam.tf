# Decrypt objects in S3
data "aws_iam_policy_document" "decrypt_object_document" {
  statement {
    sid       = "KMSAccess"
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect    = "Allow"
    resources = [
      var.s3_fs.kms_key_id
    ]
  }
}

resource "aws_iam_policy" "decrypt_object_policy" {
  name_prefix = "decrypt-${var.eks.cluster_id}"
  description = "Policy for alowing decryption of encrypted object in S3 ${var.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.decrypt_object_document.json
}

resource "aws_iam_role_policy_attachment" "decrypt_object_attachment" {
  policy_arn = aws_iam_policy.decrypt_object_policy.arn
  role       = var.eks.worker_iam_role_name
}

# Full access S3 bucket
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = var.eks.worker_iam_role_name
}