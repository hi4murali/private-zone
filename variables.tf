variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_zone_name" {
  description = "Domain name for the Route 53 private hosted zone"
  type        = string
  default     = "test.internal"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "public_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "r53-private-zone-test"
}

variable "web_server_port" {
  description = "Port the web server listens on"
  type        = number
  default     = 80
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the public instance"
  type        = string
  default     = null
}
