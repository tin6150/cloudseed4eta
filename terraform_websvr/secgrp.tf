# This is an example security group terraform defintion that is applied to the EC2 instance
# 
# Terraform currently allow using either one of:
# - a standalone Security Group Rule resource (a single ingress or egress rule), and 
# XOR
# - a Security Group resource with ingress and egress rules defined in-line.   [this example]
# but CANNOT utilize BOTH at the same time.
# Doing so will cause a conflict of rule settings and will overwrite rules.
#
#
# Security Group's Name cannot be edited after the resource is created. In fact, the name and name-prefix arguments force the creation of a new Security Group resource when they change value. In that case, Terraform first deletes the existing Security Group resource and then it creates a new one
# 
# TF security group doc:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group


## idea is to create this security group, and can make copy of it in the web gui.
## hmmm... maybe without creating any EC2 instance
## then this would just exist in the console 
## and never need to "TF destroy"

resource "aws_security_group" "tf-sg" {
  #name = "secgrp-by-tf"
  name_prefix = "tf4sg-"   # end up with name like tf4sg-20220809210640999900000001 for all ingress rules

  #### inbound rules (non ssh) ####

  ingress {
    description = "http for all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #### SSH inbound rules ####

  # allowed IP can be a comma separated list
  # update and tf apply on live system ok.
  ingress {
    description = "LBL LAN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
			"128.3.0.0/16",		# LBL
			"131.243.0.0/16",	# LBL
		]
  }
  ingress {
    description = "LBL WiFi"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ 	"198.128.192.0/19" ]
  }

  ingress {
    description = "NERSC, ESnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
			"128.55.224.0/24",	# nersc
			"198.128.0.0/14",	# ESnet
		]
  }

  ingress {
    description = "UCB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
			"169.229.192.0/24",	# UCB DC
			"136.152.0.0/16",	# UCB
		]
  }

  ingress {
    description = "UC Village, Cal Visitor"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
			"204.102.225.0/24",	# UC Village
			"204.102.226.0/24",	# UC Village
			"204.102.227.0/24",	# UC Village
			"192.31.105.0/24", 	# Cal Visitor
		]
  }


  ingress {
    description = "comcast"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "98.192.0.0/10" ]  	# comcast
    #cidr_blocks = ["98.207.88.56/24"]   # comcast
  }

  ingress {
    description = "Sonic.net"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
		      "135.180.0.0/16",
		      "192.184.128.0/17",
		      "192.160.193.0/24",
		      "198.27.128.0/17",
		      "108.169.0.0/18",
		      "142.254.0.0/17",
		      "157.131.128.0/17",
		      "157.131.64.0/18",
		      "157.234.218.0/24",
		      "173.228.0.0/20",
		      "173.228.112.0/20",
		      "173.228.16.0/20",
		      "173.228.32.0/20",
		      "184.23.0.0/16",
		      "184.23.164.0/22",
		      "184.23.192.0/18",
		      "23.93.0.0/16",
		]
  }

  #### outbound rules ####

  egress {
    description = "outbound ok for all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
	

# vim: tabstop=8
