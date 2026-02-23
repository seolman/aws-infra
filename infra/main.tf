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

# private subnet start
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

# private subnet end

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
  name = "portfolio-alb"
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

  # TODO
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
  desired_capacity = 1
  min_size = 1
  max_size = 2
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
  tag {
    key = "Name"
    value = "portfolio-instance"
    propagate_at_launch = true
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
resource "aws_s3_bucket" "portfolio_frontend_bucket" {
  bucket = "portfolio-frontend-bucket-134679"
}

resource "aws_s3_bucket_public_access_block" "portfolio_frontend_bucket_block" {
  bucket = aws_s3_bucket.portfolio_frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "portfolio_frontend_bucket_lifecycle" {
  bucket = aws_s3_bucket.portfolio_frontend_bucket.id
  rule {
    id = "move-to-onezone-ia"
    status = "Enabled"
    filter {}
    transition {
      days = 30
      storage_class = "ONEZONE_IA"
    }
  }
}

# Cloudfront
resource "aws_cloudfront_origin_access_control" "portfolio_frontend_oac" {
  name = "portfolio-frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "portfolio_frontend_cdn" {
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"

  aliases = ["demo.seolman.dev"]

  origin {
    domain_name = aws_s3_bucket.portfolio_frontend_bucket.bucket_regional_domain_name
    origin_id = "portfolio-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_frontend_oac.id
  }

  origin {
    origin_id   = "portfolio-backend"
    domain_name = aws_lb.portfolio_alb.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "portfolio-backend"

    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Origin"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "portfolio-frontend"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.portfolio_cert.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [ aws_acm_certificate_validation.portfolio_cert_valid ]
}

resource "aws_s3_bucket_policy" "portfolio_frontend_policy" {
  bucket = aws_s3_bucket.portfolio_frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.portfolio_frontend_bucket.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.portfolio_frontend_cdn.arn
          }
        }
      }
    ]
  })
}

# Route53

resource "aws_route53_zone" "portfolio_zone" {
  name = "demo.seolman.dev"
}

# ACM
provider "aws" {
  alias = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "portfolio_cert" {
  provider = aws.us_east_1
  domain_name = "demo.seolman.dev"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "portfolio_record" {
  for_each = {
    for dvo in aws_acm_certificate.portfolio_cert.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  type = each.value.type
  ttl = 60
  zone_id = aws_route53_zone.portfolio_zone.zone_id
}

resource "aws_acm_certificate_validation" "portfolio_cert_valid" {
  provider = aws.us_east_1
  certificate_arn = aws_acm_certificate.portfolio_cert.arn
  validation_record_fqdns = [ for record in aws_route53_record.portfolio_record : record.fqdn ]
}

resource "aws_route53_record" "portfolio_a_record" {
  name = "demo.seolman.dev"
  zone_id = aws_route53_zone.portfolio_zone.zone_id
  type = "A"

  alias {
    name = aws_cloudfront_distribution.portfolio_frontend_cdn.domain_name
    zone_id = aws_cloudfront_distribution.portfolio_frontend_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Redis
resource "aws_elasticache_subnet_group" "portfolio_redis_subnet_group" {
  name       = "portfolio-redis-subnet-group"
  subnet_ids = [aws_subnet.portfolio_private_subnet_a.id, aws_subnet.portfolio_private_subnet_b.id]
}

resource "aws_security_group" "portfolio_redis_sg" {
  name   = "portfolio-redis-sg"
  vpc_id = aws_vpc.portfolio_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "portfolio_redis_in" {
  security_group_id            = aws_security_group.portfolio_redis_sg.id
  referenced_security_group_id = aws_security_group.portfolio_asg_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
}

resource "aws_elasticache_cluster" "portfolio_redis" {
  cluster_id           = "portfolio-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.portfolio_redis_subnet_group.name
  security_group_ids   = [aws_security_group.portfolio_redis_sg.id]
}

# Lambda
resource "aws_iam_role" "portfolio_lambda_role" {
  name = "portfolio-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.portfolio_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  role       = aws_iam_role.portfolio_lambda_role.name
}

resource "aws_lambda_function" "portfolio_worker" {
  function_name = "portfolio-email-worker"
  role          = aws_iam_role.portfolio_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "worker.zip" # This should be created by CI/CD

  lifecycle {
    ignore_changes = [filename]
  }
}

# SNS
resource "aws_sns_topic" "portfolio_signup_topic" {
  name = "portfolio-signup-topic"
}

# SQS
resource "aws_sqs_queue" "portfolio_email_queue" {
  name = "portfolio-email-queue"
}

resource "aws_sns_topic_subscription" "portfolio_sns_to_sqs" {
  topic_arn = aws_sns_topic.portfolio_signup_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.portfolio_email_queue.arn
}

resource "aws_sqs_queue_policy" "portfolio_email_queue_policy" {
  queue_url = aws_sqs_queue.portfolio_email_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.portfolio_email_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.portfolio_signup_topic.arn
        }
      }
    }]
  })
}

resource "aws_lambda_event_source_mapping" "portfolio_sqs_trigger" {
  event_source_arn = aws_sqs_queue.portfolio_email_queue.arn
  function_name    = aws_lambda_function.portfolio_worker.arn
}

# IAM Policy for Backend to publish to SNS
resource "aws_iam_role_policy" "portfolio_backend_sns_policy" {
  name = "portfolio-backend-sns-policy"
  role = aws_iam_role.ec2_ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.portfolio_signup_topic.arn
    }]
  })
}

# WAF

# Shield

# CloudWatch

# X-Ray

# Kinesis Data Streams

# Athena

# ML
