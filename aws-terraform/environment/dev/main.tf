terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "eu-north-1"
  access_key                  = "test"
  secret_key                  = "test"

  # Skip real AWS validation checks
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Required for S3 bucket addressing in LocalStack
  s3_use_path_style           = true

  # Point services to your LocalStack container
  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
    rds = "http://localhost:4566"
    #vpc = "http://localhost:4566"
    #alb = "http://localhost:4566"

    # Add any other services you use (rds, dynamodb, lambda, sqs, etc.)
  }
}

resource "aws_s3_bucket" "app_storage"{
    bucket = "my_application_storage_bucket_2026"
    tags={
        Environment="dev"
    }

}


terraform {
  backend "s3" {
    bucket         = "tf-state-942715741252-eu-north-1"
    key            = "prod/network/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    #dynamodb_table = "terraform-state-locks" # Legacy approach
    use_lockfile = true                    # Modern Terraform 1.11+ native S3 locking
  }
}

# ---------------------------------------------------------
# 1. Application Load Balancer (Public-Facing)
# ---------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "dev-alb-sg"
  description = "Least-privilege SG for public ALB"
  vpc_id      = module.vpc.id#aws_vpc.main.id
}

# Inbound: Allow HTTPS from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow inbound HTTPS from internet"
}

# Outbound: Only allow forwarding to the App Server SG on port 8080
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Forward traffic to App Server SG"
}

# ---------------------------------------------------------
# 2. Application Server (Private Subnet)
# ---------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "dev-app-sg"
  description = "Least-privilege SG for backend application servers"
  vpc_id      = module.vpc.id#aws_vpc.main.id
}

# Inbound: Only accept traffic from the ALB SG
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Accept app traffic only from ALB SG"
}

# Outbound 1: Connect to RDS Database SG on port 5432
resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.db_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL queries to RDS SG"
}

# Outbound 2: HTTPS for AWS APIs / SSM Session Manager / Package updates
resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTPS for AWS APIs and SSM"
}

# ---------------------------------------------------------
# 3. RDS Database (Isolated Private Subnet)
# ---------------------------------------------------------
resource "aws_security_group" "db_sg" {
  name        = "prod-rds-sg"
  description = "Least-privilege SG for RDS PostgreSQL"
  vpc_id      = module.vpc.id
}

# Inbound: Only accept PostgreSQL traffic from the App Server SG
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL only from App Server SG"
}

# Outbound: Intentionally omitted (Blocks all outbound traffic by default)
