module "simple_kms_example" {
  source              = "../../../kms"
  kms_crypto_key_name = "test"
  kms_key_ring_name   = "test"
}
