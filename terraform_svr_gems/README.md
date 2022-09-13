// TF seed aws... (GEMS for now)

# Using terraform to automatically provision AWS accounts

## 1. Install Terraform (1.2.0+ required):

### CentOS
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```


### Mint/Debian
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform
```

### Mac OS X
```
$ brew install terraform
$ brew update
$ brew upgrade terraform
$ terraform --version
```

## 2. AWS credentials setup
To use your IAM credentials to authenticate the Terraform AWS provider, set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
```
$ export AWS_ACCESS_KEY_ID=
$ export AWS_SECRET_ACCESS_KEY=

if aws client is installed, and there is ~/.aws, that seems to take precedence.  
  at any rate, configure the .aws/configuration over setting the env vars if aws cli is present... 
  oh, or mv ~/.aws ~/.aws-deactivated
  but if aws-cli is installed, it is useful.  just configure that and forget about the env var...

```



## 3.  Run terraform playbook 
```
cd jumpstart_websvr
terraform init
terraform plan
terraform apply
terraform destroy  # undo everything (and hopefully nothing else that may exist under the aws account/project)
```

Here is what this playbook does:

- create VPC
- create firewall rules (security groups) for common Berkeley IP ranges
- create a tiny EC2 instance with the above network security 


========================================


Terraform destroy will remove the created security group.
So if the idea was to use this to programatically create the ingress rules,
make a copy of the security group (sg-...) before terrafly destroy



========================================


## troubleshooting notes

export TF_LOG=WARN

these messages are benign, instance still get created

2022-09-12T17:35:14.122-0700 [WARN]  Provider "registry.terraform.io/hashicorp/aws" produced an invalid plan for aws_instance.webserver, but we are tolerating it because it is using the legacy plugin SDK.
    The following problems may be the cause of any confusing errors from downstream operations:
      - .source_dest_check: planned value cty.True for a non-computed attribute
      - .user_data: planned value cty.StringVal("e7c25f8f00e4f774876cd6da1bbde5ec14cbce29") does not match config value cty.StringVal("\n#!/bin/bash\n\ntouch /tmp/SN50_terraform.flag\n\nsudo touch /SN50_terraform.flag.sudo\n\n# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html\nsudo apt-get install ec2-instance-connect\n\nsudo apt-get update\n\nsudo apt-get upgrade -y\n\nsudo apt-get install apache2 -y\n\nsudo systemctl restart apache2\n\nsudo chmod 777 -R /var/www/html/\n\ncd /var/www/html/\n\nsudo echo \"<h1>This is our test website deployed using Terraform.</h1>\" > index.html\n\n[[ test -d /root/.ssh ]] || mkdir /root/.ssh/\necho \"tbd-ssh-pub-key-string-here1\" >  /root/.ssh/sn50-test-authorized_keys\necho \"tbd-ssh-pub-key-string-here2\" >> /root/.ssh/sn50-test-authorized_keys\necho \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1fJCYUjeuR48L5JxNm6wSLYeifMcCYZu7ylFbRznxv tin@aws2208blactam.conClave\" >> /root/.ssh/authorized_keys \nchmod 700 /root/.ssh\nchmod 600 /root/.ssh/sn50-test-authorized_keys\nchmod 600 /root/.ssh/authorized_keys\n# better to have some aws method?\n# but hard coding here (or in a variable.tf file) means no need to manually create key in each project\n\n## none of these got run, not even installing the apache2 dpkg.  \n\n")
      - .get_password_data: planned value cty.False for a non-computed attribute
      - .network_interface: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .capacity_reservation_specification: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .maintenance_options: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .metadata_options: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .ebs_block_device: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .enclave_options: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .ephemeral_block_device: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead
      - .private_dns_name_options: attribute representing nested block must not be unknown itself; set nested attribute values to unknown instead

(why the GEMS main.tf only work in us-west-2 but NOT in us-east-1 is still being troubleshooted)
