variable "aws_region" {
  description = "The AWS region to deploy the EC2 instance in."
  #default   = "us-east-1"
  default = "us-west-2"
}


variable "instance_type" {
  description = "instance type for ec2"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Sn50 Value of the Name tag for the EC2 instance"
  type        = string
  default     = "TinyInstanceExample"
}
