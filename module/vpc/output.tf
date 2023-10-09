# Output Vpc

output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = aws_vpc.myVPC.id
}

output "internet_gateway" {
  value = aws_internet_gateway.igw.id
}

output "public_web_subnet_az1" {
  value = aws_subnet.public_web_subnet_az1.id
}

output "public_web_subnet_az2" {
  value = aws_subnet.public_web_subnet_az2.id
}

output "private_app_subnet_az1" {
  value = aws_subnet.private_app_subnet_az1.id
}

output "private_app_subnet_az2" {
  value = aws_subnet.private_app_subnet_az2.id
}

output "private_data_subnet_az1" {
  value = aws_subnet.private_data_subnet_az1.id
}

output "private_data_subnet_az2" {
  value = aws_subnet.private_data_subnet_az2.id
}

output "availability_zone_az1" {
  value = data.aws_availability_zones.availability_zone.names[0]
}

output "availability_zone_az2" {
  value = data.aws_availability_zones.availability_zone.names[1]
}