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
