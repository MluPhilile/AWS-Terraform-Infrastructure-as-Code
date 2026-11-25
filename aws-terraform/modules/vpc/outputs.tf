#output "vpc.id"{
#    value= module.vpc.vpc_id
#}

output "public_subnet_ids"{
    value= module.vpc.public_subnets
}

output "private_subnets_ids" {
    value= module.vpc.private_subnets
}
