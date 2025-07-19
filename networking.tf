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


# create the security group for the web application VM
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for the web application vm"
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
    cidr_blocks = [var.my_ip_cidr] # your IP CIDR block for SSH access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# create the security group for the database VM
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for the database vm"
  vpc_id      = aws_vpc.web_env_vpc.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # allow access from web server
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr] # your IP CIDR block for SSH access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# create the security group for the siem VM
resource "aws_security_group" "siem_sg" {
  name        = "siem_sg"
  description = "Security group for the SIEM vm"
  vpc_id      = aws_vpc.web_env_vpc.id
  ingress {
    from_port   = 1514 # default port for syslog
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web_env_subnet.cidr_block] # allow access from the web environment subnet
  }
  ingress {
    from_port   = 514 # another common syslog port
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web_env_subnet.cidr_block] # allow access from the web environment subnet
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr] # your IP CIDR block for SSH access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "siem-sg"
  }
}

# create the security group for the attacker VM
resource "aws_security_group" "attacker_sg" {
  name        = "attacker_sg"
  description = "Security group for the attacker vm"
  vpc_id      = aws_vpc.web_env_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr] # your IP CIDR block for SSH access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "attacker-sg"
  }
}