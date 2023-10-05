# Create a VPC
resource "aws_vpc" "MyVPC" {
  cidr_block = var.cidr_block
  tags = {
    Name = "VPC"
  }
}

# Create a Subnet1
resource "aws_subnet" "Sub1" {
  vpc_id                  = aws_vpc.MyVPC.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet 1"
  }
}

# Create a Subnet2
resource "aws_subnet" "Sub2" {
  vpc_id                  = aws_vpc.MyVPC.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet 2"
  }
}

# Create a Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Create a Route Table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Route Table"
  }
}

# Configure Route Table Association
resource "aws_route_table_association" "RT-1" {
  subnet_id       = aws_subnet.Sub1.id
  route_table_id  = aws_route_table.RT.id
}

resource "aws_route_table_association" "RT-2" {
  subnet_id       = aws_subnet.Sub2.id
  route_table_id  = aws_route_table.RT.id
}
# Create Security Group for instance
resource "aws_security_group" "SG" {
  Name         = "DevSecOps-SG"
  description  = "Security Group for DevSecOps Account"
  vpc_id       = aws_vpc.MyVPC.id

  # Inbound Rules
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "HTTP"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "SSH"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  # Outbound Rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group"
  }
  
}

# Create a Instance1
resource "aws_instance" "Instance1" {
  ami                     = "02eb7a4783e7e9317"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.SG.id]
  subnet_id               = aws_subnet.Sub1.id

  tags = {
    Name = "HelloWorld"
  }
}

# Create a Instance2
resource "aws_instance" "Instance2" {
  ami                     = "02eb7a4783e7e9317"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.SG.id]
  subnet_id               = aws_subnet.Sub2.id
  
  tags = {
    Name = "Welcome"
  }
}

# Loadblancer
resource "aws_lb" "ALB" {
  name               = "DevSecOpsALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG.id]
  subnets            = [aws_subnet.Sub1.id, aws_subnet.Sub2.id]

  tags = {
    Environment = "Staging"
  }
}

# Target Group
resource "aws_lb_target_group" "ALBtg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.MyVPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.ALBtg.arn
  target_id        = aws_instance.Instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.ALBtg.arn
  target_id        = aws_instance.Instance2.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ALBtg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.ALB.dns_name
}
