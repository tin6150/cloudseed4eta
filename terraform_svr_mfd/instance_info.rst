
this info is for the mdt instance (under gems acc).


Running Summary for add-on volumes (data vol, beyond os EBS vol created with the EC2 instance)
---------------

vol-0166c9da53a18c75b  310G as /dev/sdf    Disk /dev/nvme3n1: 310 GiB, 332859965440 bytes, 650117120 sectors    data1_pv1



~~~~~


post terraform volume addition etc info added here

xref: ~/CF_BK/aws/mdt/ ... 


2023.0623 
hima>
#xx aws ec2 start-instances   --profile gems --region us-east-2 --instance-id i-08dba0b1be02c58e0   ## old instace... ~400G / vol
#xx aws ec2 start-instances                  --region us-east-2 --instance-id i-0013d77025f8a5084   ## TF apply created this new instance, 890G  / vol.  this end up EBS and will need to pay, so destroying.

    aws ec2 start-instances                  --region us-east-2 --instance-id i-0f60315b8a7301f28   ## TF instance, 36G / vol.  

bofh>
ssh -i ~/.ssh/id_ed25519_aws2208 ec2-3-145-71-92.us-east-2.compute.amazonaws.com -l ubuntu



- swap addition for GEMS, see terraform_svr_gems/instance_info.rst
- lvm, for data volume so that disk footprint isn't so big till needed, see terraform_svr_bildaq/ and/or ~/CF_BK/aws/bild*aq



Disk summary:


Disk /dev/nvme0n1: 36 GiB, 38654705664 bytes, 75497472 sectors                # EBS backed volume for OS, need to pay gp2 price $0.1/GB/mo
/dev/nvme0n1p1  227328 75497438 75270111 35.9G Linux filesystem
/dev/nvme0n1p14   2048    10239     8192    4M BIOS boot
/dev/nvme0n1p15  10240   227327   217088  106M EFI System
Disk /dev/nvme1n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors		# ephemeral nvme cuz of instance type
Disk /dev/nvme2n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors 		# there are 2 nvme started with this machine,


eg of ephermal storage per instance type:
c5ad.4xlarge	16	32	2 x 300 NVMe SSD	Up to 10	Up to 3,170
c5ad.8xlarge	32	64	2 x 600 NVMe SSD	10	3,170
c5ad.12xlarge	48	96	2 x 900 NVMe SSD	12	4,750   # ** 
c5ad.16xlarge	64	128	2 x 1200 NVMe SSD	20	6,300
c5ad.24xlarge	96	192	2 x 1900 NVMe SSD	20	9,500


Manually add a 300G volume for use:

/mnt/data1 volume PV1:
vol-0166c9da53a18c75b  310G as /dev/sdf    Disk /dev/nvme3n1: 310 GiB, 332859965440 bytes, 650117120 sectors

sudo pvcreate /dev/nvme3n1                                # after off,on, this became /nvme1n1: 310 GiB.   good that subsequently LVM scan by signature rather than dev path!
sudo vgcreate DataVG00 /dev/nvme3n1
sudo lvcreate -n DataVol01 --size 308G  DataVG00
sudo mkfs -j /dev/DataVG00/DataVol01


/dev/mapper/DataVG00-DataVol01  303G  1.1M  287G   1% /mnt/data1





