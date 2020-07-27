provider "aws" {
 region = "ap-south-1"
 profile = "pooja"
}
resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "mytask3vpc"
  }
}
resource "aws_subnet" "Public_subnet" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "192.168.0.0/24"
 availability_zone = "ap-south-1a"
 map_public_ip_on_launch = "true"
 tags = {
  Name = "mypublicsubnet"
 }
}
resource "aws_subnet" "Private_subnet" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "192.168.32.0/24"
 availability_zone = "ap-south-1b"
 tags = {
  Name = "myprivatesubnet"
 }
}
resource "aws_internet_gateway" "mygate" { 
 vpc_id = "${aws_vpc.main.id}"
 tags = {
  Name = "myinternetgat"
 }
}
resource "aws_route_table" "myroute_table" {
 vpc_id = "${aws_vpc.main.id}"
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.mygate.id}"
 } 
 tags = {
  Name = "myowntable"
 }
}
resource "aws_route_table_association" "a1" {
 subnet_id = aws_subnet.Public_subnet.id
 route_table_id = aws_route_table.myroute_table.id
}
resource "aws_route_table_association" "b1" {
 subnet_id = aws_subnet.Private_subnet.id
 route_table_id = aws_route_table.myroute_table.id
}
resource "aws_security_group" "my_security13" {
 name = "my_security"
 vpc_id = "${aws_vpc.main.id}"
 ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
  ingress {
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
  ingress {
  description = "TCP"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
  Name = "mytask3security13"
 }
}
resource "aws_instance" "myos1" {
 ami = "ami-96d6a0f9"
 instance_type = "t2.micro"
 key_name = "my1key"
 vpc_security_group_ids = [aws_security_group.my_security13.id]
 subnet_id = "${aws_subnet.Public_subnet.id}" 
 tags = {
  Name = "MyWordOS"
 }
}
resource "aws_instance" "myos2" {
 ami = "ami-08706cb5f68222d09"
 instance_type = "t2.micro"
 key_name = "my1key"
 vpc_security_group_ids = [aws_security_group.my_security13.id]
 subnet_id = "${aws_subnet.Private_subnet.id}" 
 tags = {
  Name = "MySqlOS"
 }
}