terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "aws" {    
  # This is the provider file that tell Terraform to which provider you are using.
  # Configuration options
  region = "us-east-1"
  # set authentication 
  access_key =  # ISSO É UMA INFORMAÇÃO PRIVADA, VOCÊ TERÁ QUE USAR SUA PRÓPRIA ACCESS KEY
  secret_key =  # ISSO É UMA INFORMAÇÃO PRIVADA, VOC~E TERÁ QUE USAR SUA PRÓPRIA SECRET KEY
}
