# OpenSearch Cluster Infrastructure

Terraform project to setup opensearch cluster in AWS account.

## Configure data to deploy

You have to setup the **main.tf** file to config the deployment before apply it. You have to setup the followings variables:

1. **cluster_name**: The name of the cluster. *Ex: "opensearch-cluster"*
2. **create_vpc**: If you want create a new VPC for the deployment set to true, else set to false.
3. **stack**: Set for tagging the created resources to list them with awi tool.
4. **sg_vpc_id**: VPC security group for inbound and outbound rules. *Ex: "sg-045e9626910ddfa1b"*
5. **subnet_id**: VPC subnet id where install the cluster. *Ex: "subnet-0d3daeabdfbcc43f8"*
6. **route53_zone**: Route53 zone ID. *Ex: "Z0968496506KVSMPCSX4"*
7. **route53_domain**: Route53 domain for assign private IPs to EC2 instances. *Ex: "opensearch.local"*
8. **cidr_block**  = VPC cidr block. *Ex: "10.0.0.0/16"*
9. **subnet_availability_zones**: Subnet availability zone. *Ex: "eu-west-1b"*
10. **region**: AWS resources region.

### Setup AWS credentials

In order to deploy the infrastructure, you have to setup the AWS credentials of the account where you are goin to deploy it. You have to export the following environment variables:

```shell
export AWS_SECRET_ACCESS_KEY=XXXXXXX
export AWS_ACCESS_KEY_ID=XXXXXXX
export AWS_SESSION_TOKEN=XXXXXXX
```

### Pre-requistes for deploy
In order to deploy the services, you have to set multiples SSM parameters with essential data for the cluster. The parameters are:
1. **access_key_id**: Access Key ID of the user allowed to create snapshots in S3 repository.
2. **secret_access_key**: Secret Access Key of the user allowed to create snapshots in S3 repository.
3. **admin_password**: Opensearch admin user password.
4. **admin_password_hash**: Opensearch admin user password hashed.
5. **dashboard_password**: Opensearch dashboard user passsword.
6. **dashboard_password_hash**: Opensearch dashboard user passsword hashed.

All of this params can be set using the script __set-ssm-parameters.sh__ running with:
```shell
./set-ssm-parameters.sh
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
