# TF for EC2 instance for MFD (instance paid under GEMS)  with python
# fully activated 2023.0626.  so may not want to use terraform cmd anymore... in case change things like instance type manually (or even adding IP to security group).
# tf apply with changes to secgrp.tf will destroy old security group and create new one, but the instance/vm would be left alone (not destoryed)
# applied on tin@hima
# future start/stop: 
# aws ec2 stop-instances    --profile gems --region us-east-2 --instance-id i-0f60315b8a7301f28

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
  #region = "us-east-1"      # Virginia, don't use
  region = "us-east-2"			 # Ohio, Atlas, Bild-AQ is here.
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
  ami           = "ami-0d29ff719b07f06af"  # Ubu2204-R412-166Rlibs : + fix2 R libs (Ling + Karen skeys) us-east-2 Ohio  ## ami-0d29ff719b07f06af  is current img for gems instance i-046e5849fdbb9897a as of 2023-0623, also for mdt instance

  # instance_type change can be done without destruction , but if  type is incomptable and error result, machine will be left in stop state, and next apply will be a destroy 
  # which means content saved in the old instance would be gone!  
  #instance_type = var.instance_type
  #instance_type = "t2.micro"   # $0.020/hr  1 vCPU  0.6G RAM
  #instance_type = "t2.small"   # $0.023/hr  1 vCPU  2G
  #instance_type = "t2.medium"  # $0.046     2 vCPU  4G                # tested work for us-west-2
  #instance_type = "t3.large"   # $0.083     2 vCPU  8G
  #instance_type = "t3.xlarge"   # $0.166     4 vCPU 16G
  #instance_type = "c5a.16xlarge"  # $2.464       64 vCPU 128G 
  instance_type = "c5ad.16xlarge"  # $2.75        64 vCPU 128G 
  #~~instance_type = "c5ad.16xlarge"  # $2.75       64 vCPU 128G , 2 TB NVME Ephemeral instance storage (for swap)
  #~~instance_type = "c5ad.24xlarge"  # $4.13       96 vCPU 192G , 2 TB NVME Ephemeral instance storage (for swap)
  #~~instance_type = "m5ad.16xlarge"  # $3.30       64 vCPU 256G , 4x 600TB NVME Ephemeral instance storage (for swap)   ## manually changed to this 2023.0627
  #~~instance_type = "m6g.16xlarge"   # $2.46       64 vCPU 256G , EBS only
  #~~instance_type = "r5ad.12xlarge"  # $3.14       48 vCPU 128G , 2x 830 GB NVME Ephemeral instance storage (for swap) 
  #$$instance_type = "r5ad.24xlarge"  # $6.29/hr # changed manually??  this is the instance type (stopped) on 2023.0613
  #-instance_type = "x2gd.2xlarge"  # $0.668        8 vCPU 128G  arm64.  g = gravitron
  ## ++CHANGEME++ key_name = "EC2-keyPair-Name"  # key has to be listed by: aws ec2 describe-key-pairs
  key_name = "tin@aws2208blactam.withPass" # changing this, tf apply will destroy existing instance and recreate them.  
  #key_name = "tin@aws2208blactam.withPass-us-east-1" # keys are tied to region, and not finding key TF sometime give a vague error about resource not found
  #key_name = "fhwa" # changing this, tf apply will destroy existing instance and recreate them. # visible, but I cant use it
  vpc_security_group_ids      = [aws_security_group.tf-sg.id]  # TF will know to create new sec grp when changing region it seems
  #xx vpc_security_group_ids      = [aws_security_group.tf-sg-us-east-1.id]  # this maybe tied to region, but TF doesn't know it?
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp3"
    #volume_size           = "430"  # x2gd.2xlarge ssd is 474G
    #xx volume_size       = "891" # size in G. This would be EBS space, don't do large vol for OS, create additional vol with LVM for /mnt/data1 
    volume_size           = "36"  ## has to be larger than ami snapshot size.  if too small get error, hint needing > 31G.   OS actually use 7.3, 
    # don't be too stingy for long term OS as that would be hard to maintain.
    #https://aws.amazon.com/ec2/instance-types/c5/  
    # With C5ad instances, local NVMe-based SSDs are physically connected to the host server and provide block-level storage that is coupled to the lifetime of the instance.
    # lifetime means till machine is powered off.  after that ec2 instance may get moved and the data is not accessible.  thus the nvme is useful as swap or scratch, not LVM storage
    # some magic happens with OS image volume_size that get copied to the local nvme on boot?
    delete_on_termination = false
  }
  tags = {
    ##Name = var.instance_name
    Name = "TerraEC2_MDT"                    # duplicate name within region is allowed
    default = "EC2 Instance for MDT via Terraform"
  }


  ## instance_state = stop  ## this is return status, TF can't stop or start, only create and destroy.
  user_data_replace_on_change = true

} # this is the end of resource clause


output "IPAddress" {
  value = aws_instance.server.public_ip
}
