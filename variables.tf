variable "ansible_instance_type"{
  #default = "t2.micro"
}

variable "jenkins_instance_type"{
  #default = "t2.medium"
}

variable "ec2_key_name" {
#   default = ""
  description = "key pair for ec2 instance"   
}

variable "security_grp_id" {
  description = "security group"  
}

variable "public_subnet_id" {
  description = "public subnet id"
  
}