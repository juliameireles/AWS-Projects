# Creating EC2 instancesc within different subnets with Terraform
 1. Create a VPC with two subnets (public and private)
 2. Create a Internet Gateway e associate to the VPC 
 3. Create  a Route Table for a VPC  
 4. Add standard route to Internet Gateway 
 5. Associate Route Table to the public subnet
 6. Create Key Pair for the  instances 
 7.Create an EC2 linux instance  in the public subnet and another in the private subnet 
