resource "tls_private_key" "host_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "host_key" {
  key_name   = "host-tf"
  public_key = tls_private_key.host_key.public_key_openssh

  tags = {
    created = "github action#1"
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "main-vpc"
    created = "github action#1"
  }
}
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name    = "main-subnet"
    created = "github action#1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name    = "main-igw"
    created = "github action#1"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "public-rt"
    created = "github action#1"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ssh_sg" {
  name        = "ssh-sg"
  description = "Allow SSH inbound"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ssh-sg"
    created = "github action#1"
  }
}

resource "aws_instance" "ubuntu_ec2" {
  for_each = { for idx, name in var.instance_names : idx => name }

  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_subnet.id
  vpc_security_group_ids      = [aws_security_group.ssh_sg.id]
  key_name                    = aws_key_pair.host_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name    = each.value
    created = "github action#1"
  }
}


