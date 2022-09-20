# AWS CLI - S3 data management

## install aws cli 

```{bash}
sudo yum install awscli   # CentOs 7 eg hima
sudo apt install awscli   # Ubuntu
brew install awscli       # macos  ??

```

## configuring the aws cli client with aws account info


```{bash}
aws configure

AWS Access Key ID [None]: [Enter your personal AWS Access Key, 20 chars long]
AWS Secret Access Key [None]: [Enter the corresponding Secret/password for above key, 40 chars long]
Default region name [None]: us-west-2
Default output format [None]: table

```

Be careful with this step, leaked credentials would mean other can gain access to your aws account.

`~/.aws/credentias` contain the AWS key and secret in clear text, so make sure this file is only readable by you.

`~/.aws/config`  can be edited to say, change regio or output to text or json

Alternatively, shell environment variables AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY can be used, but be careful it get cached in the shells history file eg `~/.bash_history`


## transfering files using aws s3 command

```{bash}
aws s3 help
aws s3 ls                # ls = list all buckets

aws s3 mb help           # mb = make/create bucket                            
aws s3 mb                s3://bild-aq-tin6150  

aws s3 sync help         # sync is like unix rsync, but be careful with the folder tree structure 
aws s3 sync mySourceDir  s3://bild-aq-tin6150              # upload mySourceDir/* from my machine to cloud instance
aws s3 sync mySourceDir  s3://bild-aq-tin6150/myNewDir/    # specify a new directory name to store the content, there is no explicit "mkdir" 
aws s3 ls                s3://bild-aq-tin6150/Latest       # list the dir entry itself
aws s3 ls                s3://bild-aq-tin6150/Latest/      # list the content inside the dir

aws s3 sync s3://bild-aq-tin6150/Latest/output .           # download from cloud, to local current (.) folder

aws s3 cp   help         # cp = copy, similar to unix cp, there is a --recursive option


# setting file Access Control List so that it is public readable.  Careful!!
aws s3 mb                s3://bild-aq-tin6150-atlas
aws s3 sync atlas-git-repo   s3://bild-aq-tin6150-atlas-git-repo     --acl public-read  --exclude ".git/*"


aws s3 rb s3://bild-aq-tin6150 --force   # remove/delete bucket, and all contents inside of it. 
```

the sync command is like unix rsync

the cp   command is like unix cp or scp

Folder hierarchy is a bit unexpected, it is not quite the same as rsync or tar.  check path carefully in both source and destination.
If source path is a folder, the destination path can be any arbitrary folder name and it will be created, even if it is multiple folder path deep.
think of aws s3 doing the "mkdir -p /some/dir/structure/tree" ahead of the file sync/copy automatically.

But if the source path is a file, the destination folder path must already exist in the bucket.


## example/proposal workflow

```{bash}
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/tempo/
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/GEMs
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/LDemission
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/TRUE
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/CambiumGridEmission
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/inmap
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/EviProLite
aws s3 sync my_data_dir s3://bild-aq-tin6150-data/two-folder/deep-ok/
```

## aws ec2 instance command

```{bash}
aws ec2 describe-instances --output=table   # ascii table for human consumption
aws ec2 describe-instances --output=text    # not exactly human friendly
aws ec2 describe-instances --output=json    # definately not human friendly

aws ec2 describe-instances |  egrep "Instance|PublicDnsName|stop|terminate|running"

```

## aws cli user profile 

In addition to the `[default]` profile in ~/.aws/credentials, 
user can add additional sections for altnerate (aws) user profiles eg `[user2]`.  

Then `--profile user2` can be appended to aws command for it to be executed under that alternate profile

```
aws ec2 describe-instances --profile gems  # use default output per ~/.aws/config, and alternate profile
aws ec2 describe-instances --profile gems  | egrep "Instance|PublicDnsName|stop|terminate|running"
aws ec2 stop-instances     --profile gems --instance-id i-30d27...
aws ec2 start-instances    --profile gems --instance-id i-30d27...
```

Further info, see
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
