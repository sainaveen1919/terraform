variable "name" {
  type    = string
  default = "il"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "asg_instance_type" {
  type    = string
  default = "t3.xlarge"
}

variable "eks_version" {
  type    = string
  default = "1.30"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_database_name" {
  type    = string
  default = "integrationdb"
}

variable "rds_master_username" {
  type    = string
  default = "admin"
}

variable "api_services" {
  type = list(string)
  default = [
    "account",
    "product",
    "document",
    "payment",
    "fin-crime",
    "client",
    "notification"
  ]
}
