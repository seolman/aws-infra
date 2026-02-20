provider "aws" {
  profile = "default"
  region = "ap-northeast-2"
}

# User
resource "aws_iam_user" "portfolio_user" {
  name = "portfolio-user"
  path = "/"

  tags = {
    Description = "User for portfolio"
  }
}

resource "aws_iam_group" "portfolio_admin" {
  name = "portfolio-admin"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "portfolio_admin_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  group      = aws_iam_group.portfolio_admin.name
}

resource "aws_iam_user_group_membership" "portfolio_user_attach" {
  groups = [aws_iam_group.portfolio_admin.name]
  user   = aws_iam_user.portfolio_user.name
}

# VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "portfolio-vpc"
  }
}

resource "aws_internet_gateway" "portfolio_igw" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name = "portfolio-igw"
  }
}

resource "aws_subnet" "portfolio_public_subnet_a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "portfolio-public-subnet-a"
  }
}

resource "aws_subnet" "portfolio_public_subnet_b" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.16.0/20"
  tags = {
    Name = "portfolio-public-subnet-b"
  }
}

resource "aws_default_route_table" "public_rt" {
  default_route_table_id = aws_vpc.portfolio_vpc.default_route_table_id
  tags = {
    Name = "portfolio-public-route-table"
  }
}

resource "aws_route" "public_internet_r" {
  route_table_id = aws_default_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.portfolio_igw.id
}

resource "aws_route_table_association" "portfolio_public_assoc_a" {
  subnet_id = aws_subnet.portfolio_public_subnet_a.id
  route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_route_table_association" "portfolio_public_assoc_b" {
  subnet_id = aws_subnet.portfolio_public_subnet_b.id
  route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_subnet" "portfolio_private_subnet_a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block = "10.0.32.0/20"
  tags = {
    Name = "portfolio-private-subnet-a"
  }
}

resource "aws_subnet" "portfolio_private_subnet_b" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.48.0/20"
  tags = {
    Name = "portfolio-private-subnet-b"
  }
}

resource "aws_route_table" "portfolio_private_rt_a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name = "portfolio-private-route-table-a"
  }
}

resource "aws_route_table_association" "portfolio_private_assoc_a" {
  subnet_id = aws_subnet.portfolio_private_subnet_a.id
  route_table_id = aws_route_table.portfolio_private_rt_a.id
}

resource "aws_route_table" "portfolio_private_rt_b" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name = "portfolio-private-route-table-b"
  }
}

resource "aws_route_table_association" "portfolio_private_assoc_b" {
  subnet_id = aws_subnet.portfolio_private_subnet_b.id
  route_table_id = aws_route_table.portfolio_private_rt_b.id
}

resource "aws_eip" "portfolio_nat_eip_a" {
  domain = "vpc"
  tags = {
    Name = "portfolio-nat-eip-a"
  }
}

resource "aws_nat_gateway" "portfolio_ngw_a" {
  allocation_id = aws_eip.portfolio_nat_eip_a.id
  subnet_id = aws_subnet.portfolio_public_subnet_a.id
  depends_on = [
    aws_internet_gateway.portfolio_igw
  ]
  tags = {
    Name = "portfolio-ngw-a"
  }
}

resource "aws_route" "private_route_a" {
  route_table_id = aws_route_table.portfolio_private_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.portfolio_ngw_a.id
}

resource "aws_eip" "portfolio_nat_eip_b" {
  domain = "vpc"
  tags = {
    Name = "portfolio-nat-eip-b"
  }
}

resource "aws_nat_gateway" "portfolio_ngw_b" {
  allocation_id = aws_eip.portfolio_nat_eip_b.id
  subnet_id = aws_subnet.portfolio_public_subnet_b.id
  depends_on = [
    aws_internet_gateway.portfolio_igw
  ]
  tags = {
    Name = "portfolio-ngw-b"
  }
}

resource "aws_route" "private_route_b" {
  route_table_id = aws_route_table.portfolio_private_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.portfolio_ngw_b.id
}

resource "aws_subnet" "portfolio_database_subnet_a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block = "10.0.64.0/20"
  tags = {
    Name = "portfolio-database-subnet-a"
  }
}

resource "aws_subnet" "portfolio_database_subnet_b" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2b"
  cidr_block = "10.0.80.0/20"
  tags = {
    Name = "portfolio-database-subnet-b"
  }
}

resource "aws_subnet" "portfolio_database_subnet_c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block = "10.0.96.0/20"
  tags = {
    Name = "portfolio-database-subnet-c"
  }
}

resource "aws_route_table" "portfolio_database_rt" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name = "portfolio-database-route-table"
  }
}

resource "aws_route_table_association" "portfolio_database_assoc_a" {
  subnet_id = aws_subnet.portfolio_database_subnet_a.id
  route_table_id = aws_route_table.portfolio_database_rt.id
}

resource "aws_route_table_association" "portfolio_database_assoc_b" {
  subnet_id = aws_subnet.portfolio_database_subnet_b.id
  route_table_id = aws_route_table.portfolio_database_rt.id
}

resource "aws_route_table_association" "portfolio_database_assoc_c" {
  subnet_id = aws_subnet.portfolio_database_subnet_c.id
  route_table_id = aws_route_table.portfolio_database_rt.id
}

resource "aws_db_subnet_group" "portfolio_subnet_group" {
  name = "portfolio-subnet-group"
  subnet_ids = [
    aws_subnet.portfolio_database_subnet_a.id,
    aws_subnet.portfolio_database_subnet_b.id,
    aws_subnet.portfolio_database_subnet_c.id,
  ]
}

# ALB
# TODO https
resource "aws_security_group" "portfolio_alb_sg" {
  name = "portfolio-alb-sg"
  vpc_id = aws_vpc.portfolio_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "portfolio_alb_http_in" {
  security_group_id = aws_security_group.portfolio_alb_sg.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  to_port = 80
  from_port = 80
}

resource "aws_vpc_security_group_egress_rule" "portfolio_alb_all_out" {
  security_group_id = aws_security_group.portfolio_alb_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_lb" "portfolio_alb" {
  name = "portfolio-lb"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.portfolio_alb_sg.id
  ]
  subnets = [
    aws_subnet.portfolio_public_subnet_a.id,
    aws_subnet.portfolio_public_subnet_b.id
  ]
}

resource "aws_lb_target_group" "portfolio_tg" {
  name = "portfolio-tg"
  vpc_id = aws_vpc.portfolio_vpc.id
  port = 80
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "portfolio_http" {
  load_balancer_arn = aws_lb.portfolio_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.portfolio_tg.arn
  }
}

# ASG
resource "aws_iam_role" "ec2_ssm_role" {
  name = "portfolio-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role = aws_iam_role.ec2_ssm_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "portfolio_ec2_profile" {
  name = "portfolio-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.id
}

resource "aws_security_group" "portfolio_asg_sg" {
  name = "portfolio-asg-sg"
  vpc_id = aws_vpc.portfolio_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "portfolio_asg_http_from_alb" {
  security_group_id = aws_security_group.portfolio_asg_sg.id
  referenced_security_group_id = aws_security_group.portfolio_alb_sg.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "portfolio_asg_all_out" {
  security_group_id = aws_security_group.portfolio_asg_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_launch_template" "portfolio_lt" {
  name_prefix = "portfolio-lt-"
  image_id = "ami-0389ea382ca31bd7f"
  instance_type = "t3.micro"
  iam_instance_profile {
    arn = aws_iam_instance_profile.portfolio_ec2_profile.arn
  }

  vpc_security_group_ids = [
    aws_security_group.portfolio_asg_sg.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Welcome to Portfolio Web Service (Nginx)</h1>" > /usr/share/nginx/html/index.html
    echo "<h3>Running on: $(hostname -f)</h3>" >> /usr/share/nginx/html/index.html
    EOF
  )
}

resource "aws_autoscaling_group" "portfolio_asg" {
  name = "portfolio-asg"
  desired_capacity = 2
  min_size = 2
  max_size = 4
  vpc_zone_identifier = [
    aws_subnet.portfolio_private_subnet_a.id,
    aws_subnet.portfolio_private_subnet_b.id
  ]
  target_group_arns = [
    aws_lb_target_group.portfolio_tg.arn
  ]

  launch_template {
    id = aws_launch_template.portfolio_lt.id
    version = "$Latest"
  }
}

# RDS
resource "aws_security_group" "portfolio_db_sg" {
  name = "portfolio-db-sg"
  vpc_id = aws_vpc.portfolio_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "portfolio_db_in" {
  security_group_id = aws_security_group.portfolio_db_sg.id
  referenced_security_group_id = aws_security_group.portfolio_asg_sg.id
  ip_protocol = "tcp"
  to_port = 5432
  from_port = 5432
}

resource "aws_kms_key" "portfolio_db_key" {
  tags = {
    Name = "portfolio-db-key"
  }
}

resource "aws_db_instance" "portfolio_db" {
  allocated_storage = 20
  identifier = "portfolio-db"
  instance_class = "db.t3.micro"
  engine = "postgres"
  engine_version = "17.6"
  # multi_az = true
  db_name = "portfolio"
  username = "postgres"
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.portfolio_db_key.key_id
  db_subnet_group_name = aws_db_subnet_group.portfolio_subnet_group.id
  vpc_security_group_ids = [
    aws_security_group.portfolio_db_sg.id
  ]
  skip_final_snapshot = true
}

# S3

# Cloudfront

# WAF
