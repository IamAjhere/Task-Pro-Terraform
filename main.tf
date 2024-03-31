resource "aws_vpc" "main" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev-public-az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.123.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "dev-public-az2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.route_table.id
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "security_group" {
  name        = "dev_sg"
  description = "Dev Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

