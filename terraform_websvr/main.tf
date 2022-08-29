# example from https://linuxhint.com/ec2-instance-aws-terraform/
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

# https://medium.com/geekculture/terraform-on-gcp-creating-a-webserver-762a20bb5424
# brief GCP instance creation using TF
# lot of terms specific to GCP, 
# can't easily coax this aws-centric tf to do the same in gcp :-X

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #xxversion = "~> 3.27"
      version = "~> 4.16"
    }
  }
  #required_version = ">= 0.14.9"
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  ## ++CHANGEME++ shared_credentials_file = "/home/User_Name/.aws/credentials"
  ## or user should be ec2-user? 
  #? shared_credentials_file = "/home/tin/.aws/credentials"         # this copy from my tf execution host to the instance?
  #? profile               = "profile1"
}

resource "aws_instance" "webserver" {
  #ami = "ami-09d56f8956ab235b3"
  ami           = "ami-0aab355e1bfa1e72e"
  instance_type = var.instance_type
  ## ++CHANGEME++ key_name = "EC2-keyPair-Name"  # key has to be listed by: aws ec2 describe-key-pairs
  key_name = "tin@aws2208blactam.withPass" # changing this, tf apply will destroy existing instance and recreate them.
  vpc_security_group_ids      = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = false
  }
  tags = {
    #Name = "ExampleEC2Instance_Sn50"
    Name = var.instance_name
  }

  ## instance_state = stop  ## this is return status, TF can't stop or start, only create and destroy.
  user_data_replace_on_change = true
  user_data = <<EOF

#!/bin/bash


sudo apt-get update

sudo apt-get upgrade -y

sudo apt-get install apache2 -y

sudo systemctl restart apache2

sudo chmod 777 -R /var/www/html/

cd /var/www/html/

sudo echo "<h1>This is our test website deployed using Terraform.</h1>" > index.html

[[ test -d /root/.ssh ]] || mkdir /root/.ssh/
echo "tbd-ssh-pub-key-string-here1" >  /root/.ssh/sn50-test-authorized_keys
echo "tbd-ssh-pub-key-string-here2" >> /root/.ssh/sn50-test-authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1fJCYUjeuR48L5JxNm6wSLYeifMcCYZu7ylFbRznxv tin@aws2208blactam.conClave" >> /root/.ssh/authorized_keys 
chmod 700 /root/.ssh
chmod 600 /root/.ssh/sn50-test-authorized_keys
chmod 600 /root/.ssh/authorized_keys
# better to have some aws method?
# but hard coding here (or in a variable.tf file) means no need to manually create key in each project

## none of these got run, not even installing the apache2 dpkg.  

EOF

} # this is the end of resource clause


output "IPAddress" {
  value = aws_instance.webserver.public_ip
}
