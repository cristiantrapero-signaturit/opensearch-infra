module "opensearch" {
  source = "./modules/opensearch"
  cluster_name = "opensearch-cluster"
  create_vpc = true
  stack = "opensearch"
  sg_vpc_id = ["sg-0b90f9b50f45b306c"]
  subnet_id = "subnet-00229e79ee24eac6e"
  route53_zone = "Z0201849OCAUBDDSBU8Q"
  route53_domain = "cristiantrapero.com"
  path_to_data = "/tmp/data"
  cidr_block  = "10.0.0.0/16"
  subnet_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  region = "eu-west-1"
}