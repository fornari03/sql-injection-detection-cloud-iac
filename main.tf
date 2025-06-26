terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}



# create the VPC for all resources
resource "aws_vpc" "web_env_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "web_env_vpc"
  }
}

# create the subnet for the web environment system 
resource "aws_subnet" "web_env_subnet" {
  vpc_id            = aws_vpc.web_env_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.az

  tags = {
    Name = "web-env-subnet"
  }
}

# create the subnet for the attacker
resource "aws_subnet" "attacker_subnet" {
  vpc_id            = aws_vpc.web_env_vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = var.az

  tags = {
    Name = "attacker-subnet"
  }
}





# VARIABLES

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "az" {
  type    = string
  default = "us-east-1a"
}

variable "vm_type" {
  type    = string
  default = "t2.micro"
}