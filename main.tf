module "ec2" {
  source  = "./modules/ec2"
  ansible_instance_type_value = var.ansible_instance_type
  jenkins_instance_type_value = var.jenkins_instance_type
  ec2_key_name_value          = var.ec2_key_name
  security_grp_id_value       = [var.security_grp_id]
  public_subnet_id_value      = var.public_subnet_id
}