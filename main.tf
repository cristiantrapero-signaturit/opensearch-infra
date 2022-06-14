module "opensearch" {
  source = "./modules/opensearch"
  cluster_name = "opensearch-cluster"
  create_vpc = false
  stack = "opensearch"
  sg_vpc_id = ["sg-08526fda7d6748077"]
  subnet_id = "subnet-035974bfb8be6b138"
  route53_zone = "Z0201849OCAUBDDSBU8Q"
  route53_domain = "cristiantrapero.com"
  cidr_block  = "172.31.0.0/16"
  subnet_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  region = "eu-west-1"
}