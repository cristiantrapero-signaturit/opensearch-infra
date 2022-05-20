
variable "opensearch_nodes"{
    description = "map of nodes configuration"
    type        = map(map(string))
    default     = {
        node1 = {
            name = "opensearch-node1"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.micro"
            disk_size     = "6"
            role          = "data"
        },
        node2 = {
            name = "opensearch-node2"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.micro"
            disk_size     = "6"
            role          = "data"
            
        },
        node3 = {
            name = "opensearch-node3"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.micro"
            disk_size     = "6"
            role          = "data"
        },
        dashboard = {
            name = "opensearch-dashboard"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.micro"
            disk_size     = "6"
            role          = "dashboard"
        }
    }
}   

variable "create_vpc" {
    type            = bool
    description     = "do you want to create a new vpc?"
    default         = false
}

variable "env" {
    type            = string
    description     = "env tag"
    default         = "dev"
}

variable "cluster_name" {
    type            = string
    description     = "cluster_name"
    default         = "opensearch-cluster"
}  

variable "key_name" {
    type            = string
    description     = "Private key"
}  

variable "sg_vpc_id" {
    type            = list(string)
    description     = "sg_vcp id"
}  

variable "subnet_id" {
    type            = string
    description     = "subnet id"
}  

variable "path_to_data" {
    type            = string
    description     = "path_to_data"
    default         = "/tmp/data"
}  

variable "route53_zone" {
    type            = string
    description     = "route53 zone id"
}

variable "route53_domain" {
    type            = string
    description     = "your route53 zonde domain (dom.com)"
}

variable "cidr_block" {
    type            = string
    description     = "cidr block"
}

variable "subnet_availability_zone" {
    type            = string
    description     = "subnet_availability_zone"
}
