provider "aws" {
  region = "us-east-1" # North Virginia (US)
  access_key = "AKIAU25SIUHNICDVVZJA"
  secret_key = "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"
}

# 1. Create Virtual Private Network
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "main-gateway" {
  vpc_id = aws_vpc.main-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.main-gateway.id
  }

  tags = {
    Name = "Main Route Table"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "main-subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main Subnet"
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "main-association" {
  subnet_id      = aws_subnet.main-subnet.id
  route_table_id = aws_route_table.main-route-table.id
}

# 6. Create a Security Group
resource "aws_security_group" "main-security-group" {
  name = "allow-web-traffic"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.main-vpc.id

  ingress { # allows SSH
    description = "TLS from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # allows HTTP
    description = "TLS from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # allows HTTPS
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # allows everything
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allows-web"
  }
}

# 7. Create Network Interface with an IP in the Subnet
resource "aws_network_interface" "main-network" {
  subnet_id       = aws_subnet.main-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.main-security-group.id]

#   attachment {
#     instance     = aws_instance.test.id
#     device_index = 1
#   }
}

# 8. Assign an Elastic IP to the Network Interface
resource "aws_eip" "main-ip" {
  domain = "vpc"
  network_interface = aws_network_interface.main-network.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.main-gateway]
}

output "server_public_ip" {
    value = aws_eip.main-ip.public_ip
}

# 9. Create an Debian Server and Install/Enable Nginx
resource "aws_instance" "main-server" {
    ami = "ami-0d3eda47adff3e44b"
    instance_type = "t4g.nano"
    availability_zone = "us-east-1a"
    key_name = "main-key"
    
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.main-network.id
    }
    
    # user_data = <<-EOF
    #     #!/bin/bash
    #     sudo apt update -y
    #     sudo apt install nginx -y
    #     sudo systemctl start nginx
    #     sudo bash -c 'echo Hello Terraform! > /var/www/html/index.html'
    #     EOF

    tags = {
      Name = "main-server"
    }
}