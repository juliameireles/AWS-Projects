# Resumo do projeto 
# 1.Criar um VPC com DUAS subredes ( uma publica outra privada) --DONE
# 2.Associar um Internet Gateway e associar a VPC  --DONE
# 3. Criar um Route Table para VPC  -- DONE
# 4. Adicionar rota padrão para o Internet Gateway 
# 5. Associar Route Table à subnet pública -- DONE
# 6. Criar Key Pair para as instâncias 
# Criar uma instância EC2 Linux na subnet publica e outra na subnet privada 

# 2.Associar um Internet Gateway e associar a VPC 
resource "aws_internet_gateway" "DESAFIO-TERRAFORM-IGW" {
    vpc_id = "${aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id}"
    tags = {
        Name = "DESAFIO-TERRAFORM-IGW"
    }
}

# 3. Criar um Route Table para VPC 
resource "aws_route_table" "DESAFIO-TERRAFORM-ROUTE-TABLE" {
  vpc_id = aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DESAFIO-TERRAFORM-IGW.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.DESAFIO-TERRAFORM-IGW.id
  }

  tags = {
    Name = "DESAFIO-TERRAFORM-ROUTE-TABLE"
  }
}

resource "aws_route_table_association" "DESAFIO-TERRAFORM-RTA-PUBLIC-SUBNET-1"{
    subnet_id = "${aws_subnet.DESAFIO-TERRAFORM-PUBLIC-SUBNET-TFNAME.id}"
    route_table_id = "${aws_route_table.DESAFIO-TERRAFORM-ROUTE-TABLE.id}"
}

# Private routes
resource "aws_route_table" "DESAFIO-TERRAFORM-ROUTE-TABLE-PRIVATE" {
    vpc_id = "${aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.DESAFIO-TERRAFORM-NAT-GATEWAY.id}" 
    }
    
    tags = {
        Name = "DESAFIO-TERRAFORM-ROUTE-TABLE-PRIVATE"
    }
}

resource "aws_route_table_association" "DESAFIO-TERRAFORM-RTA-PRIVATE-SUBNET-1"{
    subnet_id = "${aws_subnet.DESAFIO-TERRAFORM-PRIVATE-SUBNET-TFNAME.id}"
    route_table_id = "${aws_route_table.DESAFIO-TERRAFORM-ROUTE-TABLE-PRIVATE.id}"
}


# NAT Gateway to allow private subnet to connect out the way
resource "aws_eip" "nat_gateway" {
    vpc = true
}
resource "aws_nat_gateway" "DESAFIO-TERRAFORM-NAT-GATEWAY" {
    allocation_id = aws_eip.nat_gateway.id
    subnet_id     = "${aws_subnet.DESAFIO-TERRAFORM-PUBLIC-SUBNET-TFNAME.id}"

    tags = {
    Name = "DESAFIO-TERRAFORM-NAT-GATEWAY-DEMO"
    }

    # To ensure proper ordering, add Internet Gateway as dependency
    depends_on = [aws_internet_gateway.DESAFIO-TERRAFORM-IGW]
}

# Security Group
resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1 # any protocol
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // Do not use this in production, should be limited to your own IP
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-allowed"
    }
}