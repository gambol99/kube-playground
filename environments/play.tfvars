#
# Playground Environment
#

# REQUIRED: An public hosted route53 domain for front facing dns
public_zone_name         = ""
# An internal domain used for internal elbs
private_zone_name        = "PLATFORM_ENV.dsp.io"
# The environment name
environment              = "PLATFORM_ENV"
# REQUIRED: You have to create a KMS key and place the KeyID here
kms_master_id            = ""
# REQUIRED: The external dns name of the kube api
kubeapi_dns              = "kube-PLATFORM_ENV"
# REQUIRED: The internal dns name of the kube api
kubeapi_internal_dns     = "kube"
# The name of the s3 bucket we will use to store secrets
secrets_bucket_name      = "dev-io-secrets-PLATFORM_ENV"
# REQUIRED: is bucket has to be create before hand
terraform_bucket_name    = "dev-io-terraform-PLATFORM_ENV"
# The subnet for the VPC
vpc_cidr                 = "10.80.0.0/16"
# Enable the calico network policy manager for kubernetes
enable_calico            = false

# Labels applied to the compute nodes
compute_labels = {
  "role"  = "compute"
}
# The addresses permitted to access the kubeapi
kubeapi_access_list = [
  "0.0.0.0/0"
]
# The addresses allows to access the bastion host
ssh_access_list = [
  "0.0.0.0/0"
]

nat_subnets = {
  "az0_cidr"  = "10.80.0.0/24"
  "az1_cidr"  = "10.80.1.0/24"
  "az2_cidr"  = "10.80.2.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
compute_subnets = {
  "az0_cidr"  = "10.80.20.0/24"
  "az1_cidr"  = "10.80.21.0/24"
  "az2_cidr"  = "10.80.22.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
secure_subnets = {
  "az0_cidr"  = "10.80.10.0/24"
  "az1_cidr"  = "10.80.11.0/24"
  "az2_cidr"  = "10.80.12.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
elb_subnets = {
  "az0_cidr"  = "10.80.100.0/24"
  "az1_cidr"  = "10.80.101.0/24"
  "az2_cidr"  = "10.80.102.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
mgmt_subnets = {
  "az0_cidr"  = "10.80.110.0/24"
  "az1_cidr"  = "10.80.111.0/24"
  "az2_cidr"  = "10.80.112.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
# The structure of this is very annoying but terraform templating and conditional support
# is awful,  hence the complex referencing.
secure_nodes = {
  "node0" = "10.80.10.100"
  "node1" = "10.80.11.100"
  "node2" = "10.80.12.100"
}
secure_nodes_zones {
  "node0_zone" = "eu-west-1a"
  "node1_zone" = "eu-west-1b"
  "node2_zone" = "eu-west-1c"
}
secure_nodes_asg = {
  "zone0_size" = 1
  "zone1_size" = 1
  "zone2_size" = 1
  "zone0_zone" = "eu-west-1a"
  "zone1_zone" = "eu-west-1b"
  "zone2_zone" = "eu-west-1c"
}
