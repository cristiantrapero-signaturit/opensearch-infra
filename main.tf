module "opensearch" {
  source = "./modules/opensearch"
  cluster_name = "opensearch-cluster"
  key_name = "opensearch"
  create_vpc = false
  sg_vpc_id = [""]
  subnet_id = ""
  route53_zone = ""
  route53_domain = "opensearch.local"
  path_to_data = "/tmp/data"
  cidr_block  = "10.0.0.0/16"
  subnet_availability_zone = "eu-west-1b"
}