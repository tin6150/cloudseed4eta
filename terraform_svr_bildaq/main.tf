# example from https://linuxhint.com/ec2-instance-aws-terraform/
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

#### somehow it works for tin+bildaq for us-west-2 but refuses in us-east-1.  ran on tin@bofh 

provider "aws" {
  ## ++CHANGEME++ check region for ec2 for this project/account.
  #region = var.aws_region
  #region = "us-west-2"      # tf does not care whats in ~/.aws/config
  region = "us-east-1"
  ## ++CHANGEME++ shared_credentials_file = "/home/User_Name/.aws/credentials"
  ## or user should be ec2-user? 
  #? shared_credentials_file = "/home/tin/.aws/credentials"         # this copy from my tf execution host to the instance?
  #? profile               = "profile1"
}

# amazon linux use ec2user@
# ubuntu@
# no obvious good image for Rocky or even CentOS...
# AMI creation based on ec2 instance (stopping req): https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html
resource "aws_instance" "server" {
  #ami           = "the_ami_are_region_specific.  Not finding it TF give a vague error about resource not found in the apply stage, cuz it is AWS barfing, yet the actual error not visible, not even when TF_LOG=INFO is set.  POS"
  #ami           = "ami-09d56f8956ab235b3"  # FC eg?
  #ami           = "ami-0c2ab3b8efb09f272"  # AmaLin 2 HVM Kernel 5.10 SSD  ## untested
  #ami           = "ami-0aab355e1bfa1e72e"  # web example, works
  #ami           = "ami-0d70546e43a941d70"  # us-west-2 oregon new ubuntu server 22.04 LTS HVM SSD root dev=ebs
  #ami           = "ami-0949257a1a378f067"  # Ubuntu2204_R411_120cranLibs = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, had 120 libs installed but then hung ## ERASE
  #ami           = "ami-00a0d9fb155b9f435"  # Ubuntu2204_R411_120cranLibs = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, 133 libs installed 
  #ami           = "ami-08b1b817db7089086"  # Ubuntu2204_R412_133cranLibs_skeys @ us-west-2 = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, 133 libs installed + LingMBP rsa key # Public, owned by tin+bildaq/lbl 0200-0742-1650
  #ami           = "ami-04448795e59349189"  # Ubuntu2204_R412_133cranLibs_skeys @ us-east-1 = ubuntu 22.04 LTS HVM SSD dev=ebs 30G + r-base 4.1.2, 133 libs installed + LingMBP rsa key # Public, owned by tin+bildaq/lbl 0200-0742-1650
  ami           = "ami-0c55cdc12f0a9d252"  # Ubu2204-R412-bild-aq : extra R libs + python3-pip + libs, karen rsa.  us-east-1

  # instance_type change can be done without destruction , but if  type is incomptable and error result, machine will be left in stop state, and next apply will be a destroy 
  # which means content saved in the old instance would be gone!  
  #instance_type = var.instance_type
  #instance_type = "t2.micro"   # $0.020/hr  1 vCPU  0.6G RAM
  #instance_type = "t2.small"   # $0.023/hr  1 vCPU  2G
  instance_type = "t2.medium"  # $0.046     2 vCPU  4G                
  #instance_type = "t3.large"   # $0.083     2 vCPU  8G
  #instance_type = "t3.xlarge"   # $0.166     4 vCPU 16G
  ##instance_type = "c5a.16xlarge"  # $2.464       64 vCPU 128G 
  #-instance_type = "x2gd.2xlarge"  # $0.668        8 vCPU 128G  arm64
  ## ++CHANGEME++ key_name = "EC2-keyPair-Name"  # key has to be listed by: aws ec2 describe-key-pairs
  key_name = "tin@aws2208blactam.withPass" # changing this, tf apply will destroy existing instance and recreate them.  
  #key_name = "tin@aws2208blactam.withPass-us-east-1" # keys are tied to region, and not finding key TF sometime give a vague error about resource not found
  #key_name = "fhwa" # changing this, tf apply will destroy existing instance and recreate them. # visible, but I cant use it
  vpc_security_group_ids      = [aws_security_group.tf-sg-all.id]  # TF is tasked to create new sec grp as part of the playbook
  associate_public_ip_address = true
  root_block_device {
    #volume_type           = "gp2"  # $0.10/GB/month 
    volume_type           = "gp3"   # $0.08/GB/month + IOPS burst fee if over 3000 IOPS
    #volume_size           = "430"  # x2gd.2xlarge ssd is 474G
    volume_size           = "30"    # AMI snapshot was 30G, so has to be at least that big
    delete_on_termination = false
  }
  tags = {
    ##Name = var.instance_name
    Name = "TerraEC2_BILDAQ"                    # duplicate name within region is allowed
    default = "EC2 Instance For BILD-AQ via Terraform"
  }


  ## instance_state = stop  ## this is return status, TF can't stop or start, only create and destroy.
  user_data_replace_on_change = true

} # this is the end of resource clause


output "IPAddress" {
  value = aws_instance.server.public_ip
}
