# Create VPC if create_vpc == true
resource "aws_vpc" "opensearch_vpc" {
  count                = (var.create_vpc == true ? 1 : 0)
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name      = "${var.stack}-vpc"
    Stack     = var.stack
    Service   = "vpc"
    Terraform = "true"
  }
}

# Create VPC subnet if create_vpc == true
resource "aws_subnet" "opensearch_subnet" {
  count             = (var.create_vpc == true ? 1 : 0)
  vpc_id            = aws_vpc.opensearch_vpc[count.index].id
  cidr_block        = var.cidr_block
  # TODO: create multiples availability zones
  availability_zone = var.subnet_availability_zones[count.index]

  tags = {
    Name      = "${var.stack}-subnet"
    Stack     = var.stack
    Service   = "subnet"
    Terraform = "true"
  }
}

# TODO: create internet interface if public_vpc == true
# Create internet gateway
# resource "aws_internet_gateway" "opensearch_igw" {
#   count  = (var.create_vpc == true ? 1 : 0)
#   vpc_id = aws_vpc.opensearch_vpc[count.index].id
#   tags = {
#     Name      = "${var.stack}-igw"
#     Stack     = var.stack
#     Service   = "${var.stack}-igw"
#     Terraform = "true"
#   }
# }

# TODO: create route table if public_vpc == true
# resource "aws_route_table" "opensearch_route_table_igw" {
#   count  = (var.create_vpc == true ? 1 : 0)
#   vpc_id = aws_vpc.opensearch_vpc[count.index].id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.opensearch_igw[count.index].id
#   }

#   tags = {
#     Name      = "${var.stack}-route-table-igw"
#     Stack     = var.stack
#     Service   = "${var.stack}-route-table-igw"
#     Terraform = "true"
#   }
# }

# TODO: create table association if public_vpc == true
# resource "aws_route_table_association" "opensearch_table_association" {
#   count          = (var.create_vpc == true ? 1 : 0)
#   subnet_id      = (var.create_vpc == true ? aws_subnet.opensearch_subnet[0].id : var.subnet_id)
#   route_table_id = aws_route_table.opensearch_route_table_igw[count.index].id

# }

resource "aws_security_group" "opensearch_security_group" {
  count       = (var.create_vpc == true ? 1 : 0)
  description = "Allow VPC traffic to communicate with AWS Services"
  vpc_id      = aws_vpc.opensearch_vpc[count.index].id
  name        = "${var.cluster_name}-security-group"

  # inter-cluster communication over ports 9200-9400
  ingress {
    from_port = 9200
    to_port   = 9400
    protocol  = "tcp"
    self      = true
  }

  # allow opensearch dashboard
  ingress {
    from_port = 5601
    to_port   = 5601
    protocol  = "tcp"
    self      = true
  }

  # allow inter-cluster ping
  ingress {
    from_port = 8
    to_port   = 0
    protocol  = "icmp"
    self      = true
  }

  # allow ssm manager
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.opensearch_vpc[count.index].cidr_block}"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.stack}-sg"
    Stack     = var.stack
    Service   = "security-group"
    Terraform = "true"
  }
}

# TODO: create ssm endpoints if public_vpc == false
resource "aws_vpc_endpoint" "ec2_messages" {
  count             = (var.create_vpc == true ? 1 : 0)
  vpc_id            = aws_vpc.opensearch_vpc[count.index].id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.opensearch_subnet[0].id]

  security_group_ids = [
    "${aws_security_group.opensearch_security_group[count.index].id}"
  ]

  private_dns_enabled = true

  tags = {
    Name      = "${var.stack}-ec2-messages-endpoint"
    Stack     = var.stack
    Service   = "vpc-endpoint"
    Terraform = "true"
  }
}

# TODO: create ssm endpoints if public_vpc == false
resource "aws_vpc_endpoint" "ssm" {
  count             = (var.create_vpc == true ? 1 : 0)
  vpc_id            = aws_vpc.opensearch_vpc[count.index].id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.opensearch_subnet[0].id]

  security_group_ids = [
    "${aws_security_group.opensearch_security_group[count.index].id}"
  ]

  private_dns_enabled = true

  tags = {
    Name      = "${var.stack}-ssm-endpoint"
    Stack     = var.stack
    Service   = "vpc-endpoint"
    Terraform = "true"
  }
}

# TODO: create ssm endpoints if public_vpc == false
resource "aws_vpc_endpoint" "ssm_messages" {
  count             = (var.create_vpc == true ? 1 : 0)
  vpc_id            = aws_vpc.opensearch_vpc[count.index].id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.opensearch_subnet[0].id]

  security_group_ids = [
    "${aws_security_group.opensearch_security_group[count.index].id}"
  ]

  private_dns_enabled = true

  tags = {
    Name      = "${var.stack}-ssm-messages-endpoint"
    Stack     = var.stack
    Service   = "vpc-endpoint"
    Terraform = "true"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count             = (var.create_vpc == true ? 1 : 0)
  vpc_id            = aws_vpc.opensearch_vpc[count.index].id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_vpc.opensearch_vpc[count.index].default_route_table_id]

  tags = {
    Name      = "${var.stack}-s3-endpoint"
    Stack     = var.stack
    Service   = "vpc-endpoint"
    Terraform = "true"
  }
}

data "template_file" "setup" {
  for_each = var.opensearch_nodes
  template = file("./source/setup.sh")
  vars = {
    cluster_name = var.cluster_name
    node_name    = "${each.value.name}.${var.route53_domain}"
    node_role    = each.value.role
    path_to_data = var.path_to_data
    domain       = "${var.route53_domain}"
  }
}

resource "aws_iam_role" "ec2-ssm-role" {
  name               = "ec2-ssm-role"
  description        = "The role for the SSM agent"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    Name      = "${var.stack}-iam-role"
    Stack     = var.stack
    Service   = "iam-role"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ec2-ssm-policy-attachment" {
  role       = aws_iam_role.ec2-ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2-ssm-iam-profile" {
  name = "ec2-ssm-iam-profile"
  role = aws_iam_role.ec2-ssm-role.name

  tags = {
    Name      = "${var.stack}-iam-instance-profile"
    Stack     = var.stack
    Service   = "iam-instance-profile"
    Terraform = "true"
  }
}


resource "aws_instance" "opensearch_cluster" {
  for_each               = var.opensearch_nodes
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  monitoring             = true
  subnet_id              = (var.create_vpc == true ? aws_subnet.opensearch_subnet[0].id : var.subnet_id)
  vpc_security_group_ids = (var.create_vpc == true ? [aws_security_group.opensearch_security_group[0].id] : var.sg_vpc_id)
  user_data              = data.template_file.setup[each.key].rendered
  iam_instance_profile   = aws_iam_instance_profile.ec2-ssm-iam-profile.id
  # ebs_block_device {
  #   device_name = "/dev/sdb"
  #   volume_size = each.value.disk_size
  #   tags = {
  #     Name      = each.value.name
  #     Stack     = var.stack
  #     Service   = "${var.stack}-ebs"
  #     Terraform = "true"
  #   }
  # }

  tags = {
    Name      = "${each.value.name}"
    role      = "${each.value.role}"
    Stack     = var.stack
    Service   = "ec2-instance"
    Terraform = "true"
  }

}


resource "aws_route53_record" "opensearch-router53" {
  for_each = aws_instance.opensearch_cluster

  zone_id = var.route53_zone
  name    = "${each.value.tags.Name}.${var.route53_domain}"
  type    = "A"
  ttl     = "300"
  records = [each.value.private_ip]

}


