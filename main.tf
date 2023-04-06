# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Generate an SSH keypair to use for the instances
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an RSA key pair
resource "aws_key_pair" "ssh_key" {
  key_name   = "my_ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create a VPC with a /16 CIDR block
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a routing table and associate it with the VPC
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
}

# Add a default route to the routing table pointing to the internet gateway
resource "aws_route" "my_default_route" {
  route_table_id         = aws_route_table.my_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create two subnets with /24 CIDR blocks
resource "aws_subnet" "my_subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Associate both subnets with the routing table
resource "aws_route_table_association" "my_subnet_1_association" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "my_subnet_2_association" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.my_rt.id
}

# Launch two t2.micro instances in each subnet using the generated SSH keypair
resource "aws_instance" "my_instance_1a" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_1.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance_1a"
  }
}

resource "aws_instance" "my_instance_1b" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_1.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance_1b"
  }
}

resource "aws_instance" "my_instance_2a" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_2.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance_2a"
  }
}

resource "aws_instance" "my_instance_2b" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_2.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance_2b"
  }
}

resource "aws_security_group" "my_sg" {
  name_prefix = "my_sg"
  vpc_id      = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow SSH traffic from any IP address
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # allow ICMP traffic from any IP address
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}

# Output the public IP addresses of the instances
output "instance_1a_public_ip" {
  value = aws_instance.my_instance_1a.public_ip
}

output "instance_1b_public_ip" {
  value = aws_instance.my_instance_1b.public_ip
}

output "instance_2a_public_ip" {
  value = aws_instance.my_instance_2a.public_ip
}

output "instance_2b_public_ip" {
  value = aws_instance.my_instance_2b.public_ip
}

output "private_key" {
  sensitive = true
  value = tls_private_key.ssh_key.private_key_pem
}