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


# create the EC2 instances for the web environment system and attacker

resource "aws_instance" "vm_database" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "vm-database"
    description = "This VM will have a PostgreSQL database installed to store the web application data"
  }
}

resource "aws_instance" "vm_web_server" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "vm-web-server"
    description = "This VM hosts the web application vulnerable to SQL injection. Also runs Snort"
  }
}

resource "aws_instance" "vm_siem" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.web_env_subnet.id
  vpc_security_group_ids      = [aws_security_group.siem_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_size = 12 # add 4 GB because of the wazuh
    volume_type = "gp3"
  }

  tags = {
    Name        = "vm-siem"
    description = "This VM will have a SIEM-like tool installed to monitor the web environment"
  }
}

resource "aws_instance" "vm_attacker" {
  ami                         = var.ami_id
  instance_type               = var.vm_type
  subnet_id                   = aws_subnet.attacker_subnet.id
  vpc_security_group_ids      = [aws_security_group.attacker_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "vm-attacker"
    description = "This VM is used by the attacker to perform SQL injection attacks against the web application"
  }
}