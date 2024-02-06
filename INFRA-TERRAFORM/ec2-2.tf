resource "aws_instance" "DESAFIO-TERRAFORM-LNX-EC2-PRIVATE-SUBNET" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"

    subnet_id = "${aws_subnet.DESAFIO-TERRAFORM-PRIVATE-SUBNET-TFNAME.id}"
    vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
    # VINCULANDO O PAR DE CHAVES A INSTÂNCIA EC2
    key_name = "${aws_key_pair.DESAFIO-EC2-1-KEY-PAIR-PRIVATE-SUBNET.id}" #aws_key_pair.this.key_name

    tags = {
        Name: "DESAFIO-TERRAFORM-LNX-EC2-PRIVATE-SUBNET"
    }
}

# CRIANDO PAR DE CHAVES 
# $ssh-keygen -f app-key-pair - CRIAR PAR DE CHAVE
# ENVIAR PAR DE CHAVE PARA AWS PARA CONECTAR A INSTÂNCIA EC2
resource "aws_key_pair" "DESAFIO-EC2-1-KEY-PAIR-PRIVATE-SUBNET" {
    key_name = "DESAFIO-EC2-1-KEY-PAIR-PRIVATE-SUBNET" # NOME DA CHAVE
    public_key = tls_private_key.rsa.public_key_openssh  # file("./modules/ec2/DESAFIO-EC2-1-KEY-PAIR-PRIVATE-SUBNET") // CHAVE PÚBLICA FICA DENTRO DA AWS
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa2" {   # CREATES A PEM (and OpenSSH) formatted private key e Também cria uma pública? 
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Guarda a chave no arquivo tfkey2

resource "local_file" "TF_KEY2" {  # Generates a local file with the given content.
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey2"
}


# É possível usar o Amazon EC2 para criar um par de chaves ED25519 ou RSA, 
#ou usar uma ferramenta de terceiros para criar um par de chaves e depois importar a chave pública
# para o Amazon EC2.

#Quando você criar um par de chaves usando o Amazon EC2, 
#a chave pública será armazenada no Amazon EC2 e você armazenará a chave privada.
