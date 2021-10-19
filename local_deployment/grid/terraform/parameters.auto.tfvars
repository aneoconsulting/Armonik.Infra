mongodb_port = 27017
redis_port = 6379
queue_port = 6380
redis_with_ssl = true
connection_redis_timeout = 10000
redis_ca_cert = "/redis_certificates/ca.crt"
redis_client_pfx = "/redis_certificates/certificate.pfx"
redis_key_file = "/redis_certificates/redis.key"
redis_cert_file = "/redis_certificates/redis.crt"
cluster_config = "local"
image_pull_policy = "IfNotPresent"
k8s_config_path = "~/.kube/config"
