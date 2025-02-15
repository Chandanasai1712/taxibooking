
resource "aws_instance" "ansible" {
    ami                     = data.aws_ami.ubuntu.id
    instance_type           = var.ansible_instance_type_value
    key_name                = var.ec2_key_name_value
    vpc_security_group_ids  = var.security_grp_id_value
    subnet_id               = var.public_subnet_id_value
    tags                    = {
        Name      = "ansible"
    }
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("./modules/ec2/files/${var.ec2_key_name_value}.pem")
      host = self.public_ip
    }


  provisioner "file" {
    source      = "./modules/ec2/files/${var.ec2_key_name_value}.pem" # Place your key in this folder which you have created
    destination = "/home/ubuntu/${var.ec2_key_name_value}.pem"
  }

  provisioner "file" {
    source = "./modules/ec2/files/jenkins-master-setup.yaml"
    destination = "/home/ubuntu/jenkins-master-setup.yaml"
  }

  provisioner "file" {
    source = "./modules/ec2/files/jenkins-slave-setup.yaml"
    destination = "/home/ubuntu/jenkins-slave-setup.yaml"
  }
  provisioner "file" {
    source = "./modules/ec2/files/ansible-hosts"
    destination = "/home/ubuntu/ansible-hosts"
  }

  provisioner "file" {
        content     = <<-EOT
    [jenkins_master]
    ${aws_instance.jenkins_master.private_ip}

    [jenkins_master:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=/opt/${var.ec2_key_name_value}.pem

    [jenkins_slave]
    ${aws_instance.jenkins_slave.private_ip}

    [jenkins_slave:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=/opt/${var.ec2_key_name_value}.pem
        EOT
        destination = "/home/ubuntu/ansible-hosts"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello!!! Initiating remote exec'",
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt update",
      "sudo apt install ansible -y",
      "ansible --version",
      "sudo mv /home/ubuntu/${var.ec2_key_name_value}.pem /opt/${var.ec2_key_name_value}.pem",
      "sudo mv /home/ubuntu/ansible-hosts /opt/ansible-hosts",
      "sudo mv /home/ubuntu/jenkins-master-setup.yaml /opt/jenkins-master-setup.yaml",
      "sudo mv /home/ubuntu/jenkins-slave-setup.yaml /opt/jenkins-slave-setup.yaml",
      "sudo chmod 400 /opt/${var.ec2_key_name_value}.pem",
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "ansible all -i /opt/ansible-hosts -m ping",
      # "ansible-playbook -i /opt/ansible-hosts /opt/jenkins-master-setup.yaml --check",
      "ansible-playbook -i /opt/ansible-hosts /opt/jenkins-master-setup.yaml",
      # "ansible-playbook -i /opt/ansible-hosts /opt/jenkins-slave-setup.yaml --check",
      "ansible-playbook -i /opt/ansible-hosts /opt/jenkins-slave-setup.yaml",
      "echo 'Fetching installed version from Jenkins Master: '",
      "ansible jenkins_master -i /opt/ansible-hosts -m shell -a 'java -version && jenkins --version'",
      "echo 'Fetching installed version from Jenkins Slave: '",
      "ansible jenkins_slave -i /opt/ansible-hosts -m shell -a 'java -version && /opt/apache-maven-3.9.6/bin/mvn -version && docker --version'",
      
      "echo 'Fetching Jenkins Admin Password from Jenkins Master...'",
      "ssh -o StrictHostKeyChecking=no -i /opt/${var.ec2_key_name_value}.pem ubuntu@${aws_instance.jenkins_master.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
    ]
  }
}  


resource "aws_instance" "jenkins_master" {
  ami                        = data.aws_ami.ubuntu.id
  instance_type              = var.jenkins_instance_type_value
  key_name                   = var.ec2_key_name_value
  vpc_security_group_ids     = var.security_grp_id_value
  subnet_id                  = var.public_subnet_id_value
  tags                       = {
    Name = "jenkins-master"
  }
  

}

resource "aws_instance" "jenkins_slave" {
  ami                        = data.aws_ami.ubuntu.id
  instance_type              = var.jenkins_instance_type_value
  key_name                   = var.ec2_key_name_value
  vpc_security_group_ids     = var.security_grp_id_value
  subnet_id                  = var.public_subnet_id_value
  tags                       = {
    Name = "jenkins-slave"
  }
  
}
