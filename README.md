# OpenSearch Cluster Infrastructure

Terraform project to setup opensearch cluster in AWS account.

## Configure data to deploy

You have to setup the **main.tf** file to config the deployment before apply it. You have to setup the followings variables:

1. **cluster_name**: The name of the cluster and AWS resources. *Ex: "opensearch-cluster"*
2. **key_name**: The key pair name for EC2 ssh access without .pem extension. *Ex: "mykeypair"*
3. **create_vpc**: If you want create a new VPC for the deployment. true or false.
4. **sg_vpc_id**: VPC security group for inbound and outbound rules. *Ex: "sg-045e9626910ddfa1b"*
5. **subnet_id**: VPC subnet id where install the cluster. *Ex: "subnet-0d3daeabdfbcc43f8"*
6. **route53_zone**: Route53 zone ID. *Ex: "Z0968496506KVSMPCSX4"*
7. **route53_domain**: Route53 domain for assign private IPs to EC2 instances. *Ex: "opensearch.local"*
8. **cidr_block**  = VPC cidr block. *Ex: "10.0.0.0/16"*
9. **subnet_availability_zones**: Subnet availability zone. *Ex: "eu-west-1b"*

### Setup AWS credentials

In order to deploy the infrastructure, you have to setup the AWS credentials of the account where you are goin to deploy it. You have to export the following environment variables:

```shell
export AWS_SECRET_ACCESS_KEY=XXXXXXX
export AWS_ACCESS_KEY_ID=XXXXXXX
```

### Deploy infrastructure

```shell
terraform init
terraform plan
terraform apply
```

### Destroy infrastructure

```shell
terraform destroy
```

### Install terraform

To install terraform in your Linux workstation run:

```shell
./install-terraform.sh
```
