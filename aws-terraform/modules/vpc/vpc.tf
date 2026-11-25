terraform{
   required_providers {
       aws={
          source = "hashcorp/aws"
          version = "~>5.0"
       }
   }
}

provider "aws" {
  region                      = "eu-north-1"
  #access_key                  = "test"
  #secret_key                  = "test"

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
    vpc = "http://localhost:4566"
    alb = "http://localhost:4566"

    # Add any other services you use (rds, dynamodb, lambda, sqs, etc.)
  }
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnet_cidrs" {
    type = list(string)
    default = ["10.0.1.0/24","10.0.2.0/24"]
}


#variable "availability_zones" {
  #type    = list(string)
  #default = ["eu-north-1a", "eu-north-1b"]
#}
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
  
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private"{
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block= var.private_subnet_cidrs[count.index]
    availability_zone= var.availability_zones[count.index]  

    tags = {
       Name = "private-subnet-${count.index + 1}"
    }
}

# Splat expression grabs all IDs from aws_subnet.private as a list
resource "aws_db_subnet_group" "subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}
#Retrieve available availability zones in current region
data "aws-availability-zones" "available"{
    state="available"
}

module "vpc"{
     source = "terrraform/vpc/aws"
     version="~> 5.0"

     name="vpc"
     cidr= var.main#"172.16.0.0/16"

     #Pick the first 2 Availability Zones
     azs= [data.aws-availability-zones.available.names[0],data.aws-availability-zones.available.names[1]]
     private_subnets=aws_subnet.private[*].id #"172.16.21.0/24","172.16.22.0/24"]
     public_subnets=aws_subnet.public[*].id#["172.16.1.0/24","172.16.2.0/24"]

     # NAT Gateway configuration for private subnets outbound internet access
     enable_nat_gateway= true
     single_nat_gateway= true
     one_nat_gateway_per_az=false

     enable_dns_hostname=true
     enable_dns_support=true

     tags = {
        #Environment= "" #production or dev
        Terraform="true"
     }

}