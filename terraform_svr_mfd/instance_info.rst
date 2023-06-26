
this info is for the mdt instance (under gems acc).


post terraform volume addition etc info added here

xref: ~/CF_BK/aws/mdt/ ... 


2023.0623 
hima>
#xx aws ec2 start-instances   --profile gems --region us-east-2 --instance-id i-08dba0b1be02c58e0   ## old instace... ~400G / vol
    aws ec2 start-instances                  --region us-east-2 --instance-id i-0013d77025f8a5084   ## TF apply created this new instance, 890G  / vol.  this end up EBS and will need to pay, destroying.

bofh>
ssh -i ~/.ssh/id_ed25519_aws2208 ec2-3-145-71-92.us-east-2.compute.amazonaws.com -l ubuntu



- swap addition for GEMS, see terraform_svr_gems/instance_info.rst
- lvm, for data volume so that disk footprint isn't so big till needed, see terraform_svr_bildaq/ and/or ~/CF_BK/aws/bild*aq



mdt instance id: i-08dba0b1be02c58e0
                    "InstanceId": "i-08dba0b1be02c58e0",
                    "InstanceType": "c5ad.16xlarge",
                    "PublicDnsName": "ec2-3-145-71-92.us-east-2.compute.amazonaws.com",   # likely change with restart

Disk summary:

these are 2 nvme started with this machine,
##xx  not adding additional (gp3) volume at this time.
Disk /dev/nvme0n1: 430 GiB, 461708984320 bytes, 901775360 sectors
Disk /dev/nvme2n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors






machine started with these dev:

Disk /dev/nvme0n1: 430 GiB, 461708984320 bytes, 901775360 sectors
	 /dev/nvme0n1p1  227328 901775326 901547999 429.9G Linux filesystem
	 /dev/nvme0n1p14   2048     10239      8192     4M BIOS boot
	 /dev/nvme0n1p15  10240    227327    217088   106M EFI System
Disk /dev/nvme2n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors



1 TB... should be quite enough.  create LVM on it.
then could still expand.


trying new trick...
have TF create a much larger OS disk ...
would need the necessary EC2 instance to run it.

890G should be safe, though some instance may not have these nvme, only EBS, may not be able to go back to smaller instance...


c5ad.4xlarge	16	32	2 x 300 NVMe SSD	Up to 10	Up to 3,170
c5ad.8xlarge	32	64	2 x 600 NVMe SSD	10	3,170
c5ad.12xlarge	48	96	2 x 900 NVMe SSD	12	4,750   # ** 
c5ad.16xlarge	64	128	2 x 1200 NVMe SSD	20	6,300
c5ad.24xlarge	96	192	2 x 1900 NVMe SSD	20	9,500


