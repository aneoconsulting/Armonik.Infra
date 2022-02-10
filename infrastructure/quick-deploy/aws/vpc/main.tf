# AWS KMS
module "kms" {
  source = "../../../modules/aws/kms"
  name   = "armonik-kms-vpc-${local.tag}-${local.random_string}"
  tags   = local.tags
}

# AWS VPC
module "vpc" {
  source = "../../../modules/aws/vpc"
  tags   = local.tags
  name   = "${var.vpc.name}-${local.tag}"
  vpc    = {
    cluster_name                                    = local.cluster_name
    private_subnets                                 = var.vpc.cidr_block_private
    public_subnets                                  = var.vpc.cidr_block_public
    main_cidr_block                                 = var.vpc.main_cidr_block
    pod_cidr_block_private                          = var.vpc.pod_cidr_block_private
    enable_private_subnet                           = var.vpc.enable_private_subnet
    enable_nat_gateway                              = var.vpc.enable_private_subnet
    single_nat_gateway                              = var.vpc.enable_private_subnet
    flow_log_cloudwatch_log_group_retention_in_days = var.vpc.flow_log_cloudwatch_log_group_retention_in_days
    flow_log_cloudwatch_log_group_kms_key_id        = (var.vpc.flow_log_cloudwatch_log_group_kms_key_id != "" ? var.vpc.flow_log_cloudwatch_log_group_kms_key_id : module.kms.selected.arn)
  }
}