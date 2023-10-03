resource "aws_vpc" "MyVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC"
  }
}


resource "aws_subnet" "Sub1" {
  vpc_id = aws_vpc.MyVPC.id
  availability_zone = "us-west-2a"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Subnet 1"
  }
}


resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "Internet Gateway"
  }
}


resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.MyVPC.id
  route = {
    Gateway_id = aws_internet_gateway.id
    cidr_block = "10.0.1.0/24"
  }

  tags = {
    Name = "Route Table"
  }
}


resource "aws_route_table_association" "RT-a" {
  subnet_id = aws_subnet.Sub1.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_security_group" "SG" {
  vpc_id = aws_vpc.MyVPC.id
  ingress = {
    description = "Allow HTTP for VPC"
    from_port = 80
    to_port = 80
    protocol = "HTTP" 
    cidr_block = [aws_vpc.VPC.cidr_block]
  }

  ingress = {
    description = "Allow SSH for VPC"
    from_port = 22
    to_port = 22
    protocol = "SSH" 
    cidr_block = [aws_vpc.VPC.cidr_block]
  }

  egress = {
    description = "Allow HTTP for VPC"
    from_port = 80
    to_port = 80
    protocol = "HTTP" 
    cidr_block = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group"
  }
  
}


resource "aws_instance" "Instance1" {
  ami = ""
  instance_type = "t2.micro"
  vpc_security_group_ids = aws_security_group.id

  tags = {
    Name = "HelloWorld"
  }
}

