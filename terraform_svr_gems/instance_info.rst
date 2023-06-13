
this info is for the gmes instance.

creating swap is quite involved!


Ref:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-swap-volumes.html
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ssd-instance-store.html#InstanceStoreTrimSupport


currently c5a.16xlarge, not exactly listed above


aws ec2 describe-instance-types \
    --filters "Name=instance-type,Values=r5*" "Name=instance-storage-supported,Values=true" \
    --query "InstanceTypes[].[InstanceType, InstanceStorageInfo.TotalSizeInGB]" \
    --output table


gems currently c5a.16xlarge, not exactly listed above
and indeed such instance has no instance storage.

maybe change to c5ad.16xlarge



manually enabling swap
if using instance storage, which is ephemeral, would 
need to be done on each instance start :-\


gonna just create a swap file and use it for now.



https://aws.amazon.com/premiumsupport/knowledge-center/ec2-memory-swap-file/

sudo dd if=/dev/zero of=/var/swapfile bs=128M count=8   # 1GB swapfile
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
sudo swapon -s 
#xx echo "/var/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
echo "/var/swapfile swap swap sw,pri=-10 0 0" | sudo tee -a /etc/fstab

# higher priority (+ve number) used first.
# want to have swap partition created out of ephemeral instance storage have higher priority
# but it tends to boil down to swapon sequence.   first on dev = higher priority


2022.1003
added a 600 GB EBS volume, which became nvme1n1  (drv# for swap on ephemeral got bumped up)
restarted as r5ad.24xlarge
?? file system /var/swapfile persisted and booted ok.


/dev/nvme1n1      259:0    0   600G  0 disk
└─/dev/nvme1n1p1  259:2    0   600G  0 part

/dev/nvme0n1      259:1    0   430G  0 disk
├─/dev/nvme0n1p1  259:3    0 429.9G  0 part /
├─/dev/nvme0n1p14 259:4    0     4M  0 part
└─/dev/nvme0n1p15 259:5    0   106M  0 part /boot/efi

for swap:

/dev/nvme2n1      259:6    0 838.2G  0 disk
/dev/nvme3n1      259:8    0 838.2G  0 disk
/dev/nvme4n1      259:7    0 838.2G  0 disk
/dev/nvme5n1      259:9    0 838.2G  0 disk


# in script ~/tin/enable_swap_ephemeral.sh
# but both EBS and ephermeral appears as /dev/nvme* 
# and if add EBS voluem, then this script needs to be updated!

::

	#!/bin/bash

	echo ""
	echo "This script creates swap partitions out of aws ephemeral storage,"
	echo "which includes destructive operations to partition the ssd"
	echo " ** !run this only once after boot only! ** "
	echo ""

	# perform various sanity check
	Entries=$(cat /proc/swaps| wc -l)
	if [[ $Entries -gt 2 ]];  then
			echo "swap partition seems enabled, this script can't handle the current state, exiting."
			exit 007
	fi


	if [[ -b /dev/nvme6n1 ]]; then
			echo "were additional EBS volume added?! unexpted nvme device path state, condition not handled by this script, exiting."
			exit 0071
	fi

	if [[ ! -b /dev/nvme5n1 ]]; then
			echo "unexpted nvme device path state, condition not handled by this script, exiting."
			exit 0077
	fi
	if [[ -b /dev/nvme2n1p1 ]]; then
			echo "partition exist already!!  condition not handled by this script, exiting."
			exit 00777
	fi

	echo ""
	echo "sleeping 60 sec to allow ctrl-c to interrupt permanent disk partition overwriting"
	echo "press ctrl-c if need to exit NOW!"
	sleep 60

	sudo parted /dev/nvme2n1 mklabel gpt
	sudo parted /dev/nvme2n1 mkpart primary linux-swap 1 50%
	sudo parted /dev/nvme3n1 mklabel gpt
	sudo parted /dev/nvme3n1 mkpart primary linux-swap 1 50%
	sudo parted /dev/nvme4n1 mklabel gpt
	sudo parted /dev/nvme4n1 mkpart primary linux-swap 1 50%
	sudo parted /dev/nvme5n1 mklabel gpt
	sudo parted /dev/nvme5n1 mkpart primary linux-swap 1 50%

	sudo parted /dev/nvme2n1 align-check optimal 1


	sudo mkswap /dev/nvme2n1p1
	sudo mkswap /dev/nvme3n1p1
	sudo mkswap /dev/nvme4n1p1
	sudo mkswap /dev/nvme5n1p1

	sudo swapon -o pri=1,discard=pages,nofail /dev/nvme2n1p1
	sudo swapon -o pri=1,discard=pages,nofail /dev/nvme3n1p1
	sudo swapon -o pri=1,discard=pages,nofail /dev/nvme4n1p1
	sudo swapon -o pri=1,discard=pages,nofail /dev/nvme5n1p1
	sudo swapoff /var/swapfile
	echo ""
	sudo swapon -s

~~~~

tin 2022.1006


~~~~~

**info on BOFH 2022.0928**
dont remember where it was supposed to fit...
but only matter if further changes are needed

r5ad.12xlarge has these nvme instance storage:

/dev/nvme1n1      259:4    0 838.2G  0 disk
/dev/nvme2n1      259:5    0 838.2G  0 disk


```{bash}
sudo parted /dev/nvme1n1 mklabel gpt
sudo parted /dev/nvme1n1 mkpart primary linux-swap 1 100%
sudo parted /dev/nvme2n1 align-check optimal 1

sudo mkswap /dev/nvme1n1p1
sudo swapon /dev/nvme1n1p1
sudo swapoff /var/swapfile

sudo parted /dev/nvme2n1 mklabel gpt
sudo parted /dev/nvme2n1 mkpart primary linux-swap 1 100%
sudo parted /dev/nvme2n1 align-check optimal 1
sudo mkswap /dev/nvme2n1p1
sudo swapon /dev/nvme2n1p1

# ideally make both swap same priority...

sudo swapon -s 
```


************************************************************
************************************************************
restart prj 2023.0613  with Andrew Bae
************************************************************
************************************************************

GEMS instance, Ling, Andrew Bae,
really use 2023-0613


https://664630251081.signin.aws.amazon.com/console
tin_gems
see 1pass


instance  TerraEC2_GEMS  i-046e5849fdbb9897a    from ami from Zack?
r5ad.24xlarge    $6.29/hr
    setup using ~/tin-gh/cloudseed4eta/terraform_svr_gems
	this is not the intance config in main.tf... 

Key pair assigned at launch: tin@aws2208blactam.withPass

2 volumes:
vol-0f92d8f62c07f1bd5   /dev/sda1   430  Attached   2022/09/25 13:16 GMT-7  No  –   No   # gp2
vol-0ab2ec2b97c4743ba   /dev/sdf    600  Attached   2022/10/03 12:37 GMT-7  No  –   No   # gp3


**>>** more notes in ~/CF_BK/aws/gems/


