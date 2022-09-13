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

# amazon linux use ec2user@
# ubuntu@
# no obvious good image for Rocky or even CentOS...
# AMI creation based on ec2 instance (stopping req): https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html
resource "aws_instance" "webserver" {
  #ami           = "ami-09d56f8956ab235b3"  # FC eg?
  #ami           = "ami-0aab355e1bfa1e72e"  # web example, works
  #ami           = "ami-0d70546e43a941d70"  # us-west-2 oregon new ubuntu server 22.04 LTS HVM SSD root dev=ebs
  #ami           = "ami-0949257a1a378f067"  # Ubuntu2204_R411_120cranLibs = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, had 120 libs installed but then hung ## ERASE
  #ami           = "ami-00a0d9fb155b9f435"  # Ubuntu2204_R412_133cranLibs = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, 133 libs installed # Public, owned by tin+bildaq/lbl 0200-0742-1650
  ami           = "ami-08b1b817db7089086"  # Ubuntu2204_R412_133cranLibs_skeys = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, 133 libs installed + LingMBP rsa key # Public, owned by tin+bildaq/lbl 0200-0742-1650
  # i-06a2cea7c6069190e   = instance id 2022.0912
  #ami           = "ami-0c2ab3b8efb09f272"  # AmaLin 2 HVM Kernel 5.10 SSD  ## untested

  #instance_type = var.instance_type
  #instance_type = "t2.micro"   # $0.020/hr  1 vCPU  0.6G RAM
  #instance_type = "t2.small"   # $0.023/hr  1 vCPU  2G
  instance_type = "t2.medium"  # $0.046     2 vCPU  4G
  #instance_type = "t3.large"   # $0.083     2 vCPU  8G
  #instance_type = "t3.xlarge"   # $0.166     4 vCPU 16G
  ## ++CHANGEME++ key_name = "EC2-keyPair-Name"  # key has to be listed by: aws ec2 describe-key-pairs
  key_name = "tin@aws2208blactam.withPass" # if make change to this, tf apply will destroy existing instance and recreate them.
  vpc_security_group_ids      = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = false
  }
  tags = {
    ##Name = var.instance_name
    Name = "TerraEC2_Sn50_libs133"
    default = "Example EC2 Instance by Sn50 Terraform"
  }

  ## instance_state = stop  ## this is return status, TF can't stop or start, only create and destroy.
  user_data_replace_on_change = true
  user_data = <<EOF

#!/bin/bash

touch /tmp/SN50_terraform.flag

sudo touch /SN50_terraform.flag.sudo

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html
sudo apt-get install ec2-instance-connect

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
