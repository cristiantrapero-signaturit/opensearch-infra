
variable "opensearch_nodes"{
    description = "map of nodes configuration"
    type        = map(map(string))
    default     = {
        master1 = {
            name = "ops-master-1"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
            disk_size     = "6"
            role          = "master"
        }
        master2 = {
            name = "ops-master-2"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
            disk_size     = "6"
            role          = "master"
            
        },
        master3 = {
            name = "ops-master-3"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
            disk_size     = "6"
            role          = "master"
        },
        node1 = {
            name = "ops-data-1"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
            disk_size     = "6"
            role          = "data"
        },
        node2 = {
            name = "ops-data-2"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
            disk_size     = "6"
            role          = "data"
        },
        dashboard = {
            name = "ops-dashboard"
            ami  = "ami-0c1bc246476a5572b"
            instance_type = "t2.medium"
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

variable "stack" {
    type            = string
    description     = "application stack name"
    default         = "opensearch"
}

variable "cluster_name" {
    type            = string
    description     = "cluster_name"
    default         = "opensearch-cluster"
}  


variable "sg_vpc_id" {
    type            = list(string)
    description     = "security group vpc id"
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
    description     = "your route53 zone domain (domain.com)"
}

variable "cidr_block" {
    type            = string
    description     = "cidr block"
}

variable "subnet_availability_zones" {
    type            = list(string)
    description     = "subnet_availability_zones"
}

variable "region" {
    type            = string
    description     = "region where deploy the service"
}
