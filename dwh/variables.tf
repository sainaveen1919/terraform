variable "name" {
  type    = string
  default = "dwh"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "asg_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "redshift_node_type" {
  type    = string
  default = "ra3.large"
}

variable "redshift_database_name" {
  type    = string
  default = "dwh"
}

variable "redshift_master_username" {
  type    = string
  default = "admin"
}
