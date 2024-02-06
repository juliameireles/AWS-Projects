resource "aws_instance" "DESAFIO-TERRAFORM-LNX-EC2-PUBLIC-SUBNET" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"

    subnet_id = "${aws_subnet.DESAFIO-TERRAFORM-PUBLIC-SUBNET-TFNAME.id}"
    vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
    key_name = "${aws_key_pair.DESAFIO-EC2-1-KEY-PAIR-PUBLIC-SUBNET.id}"

    tags = {
        Name: "DESAFIO-TERRAFORM-LNX-EC2-PUBLIC-SUBNET"
    }
}
// recurso para criar a key pair
# When importing an existing key pair the public key material may be in any
# format supported by AWS. Supported formats (per the AWS documentation) are:
#OpenSSH public key format (the format in ~/.ssh/authorized_keys)
resource "aws_key_pair" "DESAFIO-EC2-1-KEY-PAIR-PUBLIC-SUBNET" {
    key_name = "DESAFIO-EC2-1-KEY-PAIR-PUBLIC-SUBNET"
    public_key = tls_private_key.rsa.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Guarda a chave no arquivo  
resource "local_file" "TF_KEY" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}