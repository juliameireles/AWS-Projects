
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}


provider "aws" {
  # Configuration options
  region = "us-east-1" # Virgínia
  # set authentication 
  access_key =   # ISSO É UMA INFORMAÇÃO PRIVADA, VOCÊ TERÁ QUE USAR SUA PRÓPRIA ACCESS KEY
  secret_key =   # ISSO É UMA INFORMAÇÃO PRIVADA, VOCÊ TERÁ QUE USAR SUA PRÓPRIA SECRET KEY
}

# RESUMO DO PROJETO 1

# 1. Create a VPC --DONE
# 2. Create Internet Gateway -- DONE
# 3. Create Custom Route Table -- DONE
# 4. Create a subnet --DONE
# 5. Associate subnet with Route Table --DONE
# 6. Create Security Group to allow port 22(SSH),80(HTTP),443(HTTPS) // determina que tipo de tráfego é permitido para EC2 --DONE
# 7. Create a network interface with an ip in the subnet that was created in step 4 --DONE
# 8. Assign an elastic IP to the network interface created in step 7  // ELASTIC IP, O QUE É? --DONE
# 9. Create Ubuntu server and install/enable apache2
# 10. Outside of Terraform: CREATE A KEYPAIR --DONE

# 1. Create a VPC
resource "aws_vpc" "WEB-SERVER-PROJECT1-TERRAFORM-VPC-TFNAME" {
    cidr_block = "10.0.0.0/16"    
    tags = {
        Name = "WEB-SERVER-PROJECT1-TERRAFORM-VPC"
    }
  
}

# 2. Create Internet Gateway 
resource "aws_internet_gateway" "TERRAFORM-GATEWAY-PROJECT1-TFNAME" {
  vpc_id = aws_vpc.WEB-SERVER-PROJECT1-TERRAFORM-VPC-TFNAME.id

  tags = {
    Name = "TERRAFORM-GATEWAY-PROJECT1"
  }
}
# 3. Create Custom Route Table
resource "aws_route_table" "TERRAFORM-ROUTE-TABLE-PROJECT1-TFNAME" {
  vpc_id = aws_vpc.WEB-SERVER-PROJECT1-TERRAFORM-VPC-TFNAME.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0" # vamos enviar essa subnet, todo o tráfego ( ou vpc?) para o internet gateway  --> IPV4
    gateway_id = aws_internet_gateway.TERRAFORM-GATEWAY-PROJECT1-TFNAME.id
  }

  route {
    ipv6_cidr_block        = "::/0" #anywhere   Novamente, permite que o nosso tráfego da subnet possa ir para a internet --> IPV6
    gateway_id = aws_internet_gateway.TERRAFORM-GATEWAY-PROJECT1-TFNAME.id
  }

  tags = {
    Name = "TERRAFORM-ROUTE-TABLE-PROJECT1"
  }
}
# 4. Create a subnet
resource "aws_subnet" "TERRAFORM-SUBNET-PROJECT1-TFNAME" {
  vpc_id     = aws_vpc.WEB-SERVER-PROJECT1-TERRAFORM-VPC-TFNAME.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "TERRAFORM-SUBNET-PROJECT1"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.TERRAFORM-SUBNET-PROJECT1-TFNAME.id
  route_table_id = aws_route_table.TERRAFORM-ROUTE-TABLE-PROJECT1-TFNAME.id
}

# 6. Create Security Group to allow port 22(SSH),80(HTTP),443(HTTPS) // determina que tipo de tráfego é permitido para EC2
resource "aws_security_group" "SG-ALLOW-WEB-TRAFFIC-EC2" {
  name        = "allow_tls"
  description = "Allow web traffic traffic"
  vpc_id      = aws_vpc.WEB-SERVER-PROJECT1-TERRAFORM-VPC-TFNAME.id

  ingress { 
    description = "HTTPS"
    from_port   = 443 #range of ports
    to_port     = 443 # range of ports
    protocol    = "tcp" # layer 4 (transport layer)
    cidr_blocks = ["0.0.0.0/0"] # any IP adress can access
  }

  ingress { 
    description = "HTTP"
    from_port   = 80 #range of ports
    to_port     = 80 # range of ports
    protocol    = "tcp" # layer 4 (transport layer)
    cidr_blocks = ["0.0.0.0/0"] # any IP adress can access
  }

  ingress { 
    description = "SSH"
    from_port   = 22 #range of ports
    to_port     = 22 # range of ports
    protocol    = "tcp" # layer 4 (transport layer)
    cidr_blocks = ["0.0.0.0/0"] # any IP adress can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TERRAFORM-ALLOW-WEB-PROJECT1"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4 
# CRIANDO O IP PRIVADO PARA O HOST
resource "aws_network_interface" "TERRAFORM-WEB-SERVER-NIC-TFNAME" {
  subnet_id       = aws_subnet.TERRAFORM-SUBNET-PROJECT1-TFNAME.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.SG-ALLOW-WEB-TRAFFIC-EC2.id]

}

# 8. Assign an elastic IP to the network interface created in step 7  // ELASTIC IP, O QUE É?
# CRIANDO UM IP PÚBLICO PARA O HOST
# PARA CRIAR UM ELASTIC IP, VOCÊ PRECISAR CRIAR UM INTERNET GATEWAY ANTES 
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.TERRAFORM-WEB-SERVER-NIC-TFNAME.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.TERRAFORM-GATEWAY-PROJECT1-TFNAME]
}

resource "aws_instance" "TERRAFORM-WEB-SERVER-EC2-PROJECT1" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a" # mesma AZ que a subnet
    key_name = "TERRAFORM-PROJET-1-KEY-PAIR"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.TERRAFORM-WEB-SERVER-NIC-TFNAME.id
    }
user_data = <<-EOF
     #!/bin/bash
     sudo apt update 
     sudo apt install  apache2 -y
     sudo systemctl start apache2
     sudo bash -c 'echo MEU PRIMEIRO WEB SERVER PELO TERRAFORM > /var/www/html/index.html'
EOF

  
  tags = {
    Name = "TERRAFORM-WEB-SERVER-EC2-PROJECT1"
  }
}

