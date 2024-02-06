
# Resumo do projeto 
# 1.Criar um VPC com DUAS subredes ( uma publica outra privada)
# 2.Associar um Internet Gateway e associar a VPC  
# 3. Criar um Route Table para VPC 
# 4. Adicionar rota padrão para o Internet Gateway 
# 5. Associar Route Table à subnet pública 
# 6. Criar Key Pair para as instâncias 
# Criar uma instância EC2 Linux na subnet publica e outra na subnet privada 

# 1.Criar um VPC com DUAS subredes ( uma publica outra privada)
resource "aws_vpc" "DESAFIO-TERRAFORM-VPC-TFNAME" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "DESAFIO-TERRAFORM-VPC"
  }
}


#Multiple AWS VPC public subnets would be reachable from the internet; 
#which means traffic from the internet can hit a machine in the public subnet.
resource "aws_subnet" "DESAFIO-TERRAFORM-PUBLIC-SUBNET-TFNAME" {
  vpc_id     = aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true" # This is what makes it a public subnet
  availability_zone = "us-east-1a"


  tags = {
    Name = "DESAFIO-TERRAFORM-PUBLIC-SUBNET"
  }
}

# Multiple AWS VPC private subnets which mean it is not reachable to the 
#internet directly without NAT Gateway.
resource "aws_subnet" "DESAFIO-TERRAFORM-PRIVATE-SUBNET-TFNAME" {
  vpc_id     = aws_vpc.DESAFIO-TERRAFORM-VPC-TFNAME.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "DESAFIO-TERRAFORM-PRIVATE-SUBNET"
  }
}