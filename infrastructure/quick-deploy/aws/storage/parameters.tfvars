# Profile
profile = "default"

# Region
region = "eu-west-3"

# TAG
tag = "main"

# S3 as shared storage
s3_fs = {
  name       = "armonik-s3fs"
  kms_key_id = ""
}

# VPC info
vpc         = {
  id                     = ""
  cidr_block             = ""
  private_subnet_ids     = []
  pod_cidr_block_private = []
  pods_subnet_ids        = []
}

# AWS Elasticache
elasticache = {
  name                  = "armonik-elasticache"
  engine                = "redis"
  engine_version        = "6.x"
  node_type             = "cache.r4.large"
  encryption_keys       = {
    kms_key_id     = ""
    log_kms_key_id = ""
  }
  log_retention_in_days = 30
  multi_az_enabled      = false
  cluster_mode          = {
    replicas_per_node_group = 0
    num_node_groups         = 1 #Valid values are 0 to 5
  }
}

# MQ parameters
mq = {
  name                    = "armonik-mq"
  engine_type             = "ActiveMQ"
  engine_version          = "5.16.3"
  host_instance_type      = "mq.m5.large"
  deployment_mode         = "SINGLE_INSTANCE" #"ACTIVE_STANDBY_MULTI_AZ"
  storage_type            = "efs" #"ebs"
  kms_key_id              = ""
  authentication_strategy = "simple" #"ldap"
  publicly_accessible     = false
}

# MQ Credentials
mq_credentials = {
  password = "MindTheGapOfPassword"
  username = "ExampleUser"
}