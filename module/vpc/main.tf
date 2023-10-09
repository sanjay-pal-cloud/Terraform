# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = false

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = "${var.environment}"
    Application-Type = "${var.application_type}"
    Customer-Name = "${var.customer_name}"
  }
}

# Get all Availability Zones in region
data "aws_availability_zones" "availability_zone" {}

# Create a Public web Subnet in az1
resource "aws_subnet" "public_web_subnet_az1" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[0]
  cidr_block = var.public_web_subnet_az1_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.application_type}${var.customer_name}-PublicSubnet-az1"
  }
}

# Create a Public web Subnet in az2
resource "aws_subnet" "public_web_subnet_az2" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[1]
  cidr_block = var.public_web_subnet_az2_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.application_type}${var.customer_name}-PublicSubnet-az2"
  }
}

# Create a Private app Subnet in az1
resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[0]
  cidr_block = var.private_app_subnet_az1_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_type}${var.customer_name}-AppPrivateSubnet-az1"
  }
}

# Create a Private app Subnet in az2
resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[1]
  cidr_block = var.private_app_subnet_az1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application_type}${var.customer_name}-AppPrivateSubnet-az2"
  }
}

# Create a Private data Subnet in az1
resource "aws_subnet" "private_data_subnet_az1" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[0]
  cidr_block = var.private_data_subnet_az1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application_type}${var.customer_name}-DBPrivateSubnet-az1"
  }
}

# Create a Private data Subnet in az2
resource "aws_subnet" "private_data_subnet_az2" {
  vpc_id = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.availability_zone.names[1]
  cidr_block = var.private_data_subnet_az1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application_type}${var.customer_name}-DbPrivateSubnet-az2"
  }
}

# Create a Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "${var.application_type}${var.customer_name}-${var.environment}-igw"
  }
} 

# create a Route Table 
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.application_type}${var.customer_name}-${var.environment}-Public-RT"
  }
}

# Associate Public RT with Public Subnet in Az1
resource "aws_route_table_association" "public_az1_rt_association" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id = aws_subnet.public_web_subnet_az1.id
}

# Associate Public RT with Public Subnet in Az2
resource "aws_route_table_association" "public_az2_rt_association" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id = aws_subnet.public_web_subnet_az2.id
}