module "opensearch" {
  source = "./modules/opensearch"
  cluster_name = "opensearch-cluster"
  create_vpc = false
  stack = "opensearch"
  sg_vpc_id = ["sg-066c895752d9cb6d8"]
  subnet_id = "subnet-08ed6593932ffb22e"
  route53_zone = "Z09247162ZMZ5VPJULBQF"
  route53_domain = "opensearch.local"
  cidr_block  = "172.31.0.0/16"
  subnet_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  region = "eu-west-1"
}