region = "eu-north-1"
environment = "development_environment"
instance_type = "t3.micro"
instance_name = "my-instance"
#instance_id = aws_instance.var.instance_name.id
private_subnets = [ "172.31.0.0/16","172.31.0.0/16" ]
public_subnets = [ "0.0.0.0/0","0.0.0.0/0"]
vpc_cidr = "172.16.0.0/16"

#vpc_id = "value"
