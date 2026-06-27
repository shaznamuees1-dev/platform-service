provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "platform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "platform-service-vpc"
  }
}

resource "aws_subnet" "platform_subnet" {
  vpc_id                  = aws_vpc.platform_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "platform-service-subnet"
  }
}

resource "aws_internet_gateway" "platform_igw" {
  vpc_id = aws_vpc.platform_vpc.id
  tags = {
    Name = "platform-service-igw"
  }
}

resource "aws_route_table" "platform_rt" {
  vpc_id = aws_vpc.platform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.platform_igw.id
  }

  tags = {
    Name = "platform-service-rt"
  }
}

resource "aws_route_table_association" "platform_rta" {
  subnet_id      = aws_subnet.platform_subnet.id
  route_table_id = aws_route_table.platform_rt.id
}

resource "aws_key_pair" "platform_key" {
  key_name   = "platform-service-key"
  public_key = file("${path.module}/platform-key.pub")
}

resource "aws_security_group" "platform_sg" {
  name        = "platform-service-sg"
  description = "Allow SSH and app port"
  vpc_id      = aws_vpc.platform_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "platform_ec2" {
  ami                    = "ami-0672fd5b9210aa093"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.platform_key.key_name
  vpc_security_group_ids = [aws_security_group.platform_sg.id]
  subnet_id              = aws_subnet.platform_subnet.id

  tags = {
    Name = "platform-service-terraform"
  }
}
