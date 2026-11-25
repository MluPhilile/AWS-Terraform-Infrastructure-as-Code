variable "region" {
    type = string
    description = "the region name"
  
}

variable "vpc_cidr" {
    type = string
}

variable "public_subnets"{
    type=list(string)
}
variable "private_subnets" {
    type=list(string)
  
}

variable "vpc_id" {
    type=string
}

variable "environment" {
    type = string
    description = "envorinment deployment name"
}
variable "instance_type" {
    type=string
}
variable "instance_name" {
    type=string
}

variable "enable_monitoring" {
    type=bool
}
variable "tags"{
    type=map(string)
}