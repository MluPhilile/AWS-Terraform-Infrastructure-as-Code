module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "my-instance"

  instance_type = "t3.micro"
  key_name      = "my_instance"
  monitoring    = true
  subnet_id     = module.vpc.private_subnets.ids[0]

  tags = {
    Terraform   = "true" 
    Environment = "dev"
  }
}
