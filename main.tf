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

# create the security group for the web environment system
resource "aws_security_group" "web_env_sg" {
  name        = "web_sg"
  description = "Security group for web environment"
  vpc_id      = aws_vpc.web_env_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.web_env_vpc.cidr_block] # allow PostgreSQL access from within the VPC
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-env-sg"
  }
}

# create the Internet Gateway attached to the VPC
resource "aws_internet_gateway" "web_env_igw" {
  vpc_id = aws_vpc.web_env_vpc.id

  tags = {
    Name = "web-env-igw"
  }
}

# create the Route Table for the web env subnet
resource "aws_route_table" "web_env_public_rt" {
  vpc_id = aws_vpc.web_env_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_env_igw.id
  }

  tags = {
    Name = "web-env-public-rt"
  }
}

# associate the Route Table with the public subnet
resource "aws_route_table_association" "web_env_public_assoc" {
  subnet_id      = aws_subnet.web_env_subnet.id
  route_table_id = aws_route_table.web_env_public_rt.id
}

# create the Route Table for the attacker subnet
resource "aws_route_table" "attacker_public_rt" {
  vpc_id = aws_vpc.web_env_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_env_igw.id
  }

  tags = {
    Name = "attacker-public-rt"
  }
}

# associate the Route Table with the attacker subnet
resource "aws_route_table_association" "attacker_public_assoc" {
  subnet_id      = aws_subnet.attacker_subnet.id
  route_table_id = aws_route_table.attacker_public_rt.id
}


# create the EC2 instances for the web environment system and attacker

resource "aws_instance" "vm_database" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_env_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "vm-database"
  }
}

resource "aws_instance" "vm_web_server" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_env_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "vm-web-server"
  }
}

resource "aws_instance" "vm_sec_monitor" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_env_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "vm-sec-monitor"
    description = "This VM will have Snort, iptables and a SIEM-like tool installed for security and monitoring"
  }
}

resource "aws_instance" "vm_attacker" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.attacker_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_env_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "vm-attacker"
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

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-020cba7c55df1f615" # Ubuntu Server 24.04 LTS (HVM),EBS General Purpose (SSD) AMI for us-east-1
}

variable "key_name" {
  description = "Name of the SSH key pair you created in AWS to use for the EC2 instance"
  type        = string
}