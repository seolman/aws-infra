provider "aws" {
  profile = "default"
  region = "ap-northeast-2"
}

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
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio_igw.id
  }
  tags = {
    Name = "portfolio-public-route-table"
  }
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

resource "aws_route_table" "portfolio_private_rt" {
  vpc_id = aws_vpc.portfolio_vpc.id
  tags = {
    Name = "portfolio-private-route-table"
  }
}

resource "aws_route_table_association" "portfolio_private_assoc_a" {
  subnet_id = aws_subnet.portfolio_private_subnet_a.id
  route_table_id = aws_route_table.portfolio_private_rt.id
}

resource "aws_route_table_association" "portfolio_private_assoc_b" {
  subnet_id = aws_subnet.portfolio_private_subnet_b.id
  route_table_id = aws_route_table.portfolio_private_rt.id
}

# resource "aws_nat_gateway" "portfolio_ngw_a" {
#   subnet_id = aws_subnet.portfolio_private_subnet_a.id
# }
#
# resource "aws_nat_gateway" "portfolio_ngw_b" {
#   subnet_id = aws_subnet.portfolio_private_subnet_b.id
# }

# resource "aws_subnet" "portfolio_database_subnet_a" {
#   vpc_id = aws_vpc.portfolio_vpc.id
#   availability_zone = "ap-northeast-2a"
#   cidr_block = "10.0.60.0/20"
#   tags = {
#     Name = "portfolio_database_subnet_a"
#   }
# }
#
# resource "aws_subnet" "portfolio_database_subnet_b" {
#   vpc_id = aws_vpc.portfolio_vpc.id
#   availability_zone = "ap-northeast-2b"
#   cidr_block = "10.0.72.0/20"
#   tags = {
#     Name = "portfolio_database_subnet_b"
#   }
# }
