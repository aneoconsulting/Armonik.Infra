data "aws_caller_identity" "current" {}

# this external provider is used to get date during the plan step.
data "external" "static_timestamp" {
  program = ["date", "+{ \"creation_date\": \"%Y/%m/%d %T\" }"]
}

# this resource is just used to prevent change of the creation_date during successive 'terraform apply'
resource "null_resource" "timestamp" {
  triggers = {
    creation_date = data.external.static_timestamp.result.creation_date
  }
  lifecycle {
    ignore_changes = [triggers]
  }
}

locals {
  tags = {
    env             = "test"
    app             = "complete"
    module          = "AWS SQS"
    "create by"     = data.aws_caller_identity.current.arn
    "creation date" = null_resource.timestamp.triggers["creation_date"]
  }
}


module "fifo_sse_cmk_encrypted_dlq_sqs" {
  source = "../../../sqs"

  # This is a separate queue used as a dead letter queue for the above example
  # instead of the module creating both the queue and dead letter queue together

  name                              = "test-sqs-sse-dlq"
  sqs_managed_sse_enabled           = true
  fifo_queue                        = true
  kms_master_key_id                 = aws_kms_key.this.id
  kms_data_key_reuse_period_seconds = 3600

  # Dead letter queue
  dlq_redrive_allow_policy = {
    sourceQueueArns = [module.fifo_sse_cmk_encrypted_dlq_sqs.queue_arn]
  }

  tags = local.tags
}

resource "aws_kms_key" "this" {}
