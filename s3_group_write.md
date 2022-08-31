

creating s3 bucket that is group writable takes some work!

plan:
create a 
eta_s3_policy.json
bildaq_s3_policy.json # later when ready to add nrel team

that list all collaborator (email?  aws acc id?)
then use ansible to apply the policy to a bucket
(ansible can create the bucket, which hopefully can be renamed later if needed, if not, update ansible play).

alt 1: create a ARN access policy that is limited to the VPC
so instances created within the VPC will have full access to the s3 bucket.

worse case is to configure an AWS key pair that get stored in the instance and folks can use that to read/write to s3 
(api to limit key to only such s3 acceess)


policy file desc, see:
https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-with-s3-actions.html



https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_s3_module.html does not list poilcy support 
https://github.com/ansible-collections/amazon.aws/blob/stable-4/docs/amazon.aws.s3_bucket_module.rst does list policy via json... investigate
policy json desc: https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html



references

https://tomgregory.com/s3-bucket-access-from-the-same-and-another-aws-account/

https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/#:%7E:text=Using%20cross-account%20IAM%20roles,AWS%20account%20or%20AWS%20services.


acc id
020007421650
tin+bildaq@lbl.gov

for starter, add 
```
020007421650/* 
for all user in the acc? 
```
