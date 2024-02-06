variable "AWS_REGION" {    
    default = "us-east-1"
}
variable "AMI" {
    type = map(string)

    default = {
        # we are using ubuntu for both instances
        us-east-1 = "ami-0fc5d935ebf8bc3bc" # Ubuntu 20.04 x86
    }
}
variable "EC2_USER" {
    default = "ubuntu"
}
