variable "s3" {
  description = "name your s3 bucket"
}

variable "vpc_cidr" {
  description = "CIDR for vpc"
}

variable "subnet_cidr" {
  description = "your subnet cidr"
}

variable "ec2_ami" {
  description = "Provide instance ami value"
}

variable "instance_type" {
  description = "your instance type such as t2.micro, etc."
}