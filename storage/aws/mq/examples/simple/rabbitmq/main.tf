# Current account
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "rabbitmq" {
  source = "../../../../mq"
  tags = {
    env             = "test"
    app             = "simple"
    module          = "AWS S3"
    "create by"     = data.aws_caller_identity.current.arn
    "creation date" = null_resource.timestamp.triggers["creation_date"]
  }
  name               = "test-mq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.10.20"
  host_instance_type = "mq.m5.xlarge"
  vpc_cidr_blocks    = [data.aws_vpc.default.cidr_block]
  vpc_id             = data.aws_vpc.default.id
  vpc_subnet_ids     = data.aws_subnets.subnets.ids
}
