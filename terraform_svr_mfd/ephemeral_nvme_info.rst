
this info is for the mdt instance (under gems acc).


hima>
#xx aws ec2 start-instances   --profile gems --region us-east-2 --instance-id i-08dba0b1be02c58e0
    aws ec2 start-instances                  --region us-east-2 --instance-id i-08dba0b1be02c58e0



mdt instance id: i-08dba0b1be02c58e0
                    "InstanceId": "i-08dba0b1be02c58e0",
                    "InstanceType": "c5ad.16xlarge",

Disk summary:

these are 2 nvme started with this machine,
they are EPHEMERAL, gone when VM is powered off
there must be some trick that the OS data is preserved outside... maybe when powering off it get flushed elsewhere
Hmm... what if terraform create a larger disk ??
Disk /dev/nvme0n1: 430 GiB, 461708984320 bytes, 901775360 sectors
Disk /dev/nvme2n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors




machine started with these dev:

Disk /dev/nvme0n1: 430 GiB, 461708984320 bytes, 901775360 sectors
	 /dev/nvme0n1p1  227328 901775326 901547999 429.9G Linux filesystem
	 /dev/nvme0n1p14   2048     10239      8192     4M BIOS boot
	 /dev/nvme0n1p15  10240    227327    217088   106M EFI System
Disk /dev/nvme2n1: 1.09 TiB, 1200000000000 bytes, 2343750000 sectors




first vol with root disk can also add partition for additional FS/LVM
sudo parted /dev/nvme0n1 print
Model: Amazon Elastic Block Store (nvme)
Disk /dev/nvme0n1: 462GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
14      1049kB  5243kB  4194kB                     bios_grub
15      5243kB  116MB   111MB   fat32              boot, esp
 1      116MB   462GB   462GB   ext4

~~~~~


sudo pvcreate /dev/nvme1n1
sudo vgcreate DataVG00  /dev/nvme1n1
sudo lvcreate -n DataVol01 --size 950G DataVG00
sudo lvextend -L+160G /dev/DataVG00/DataVol01    # ~7.9G left
sudo mkfs -j /dev/DataVG00/DataVol01

/dev/mapper/DataVG00-DataVol01  1.1T   77M  1.1T   1% /mnt/data1

this LVM config was not accessible after power off 
(and when aws decides to retire the instance from the physical server).

quick reboot may persist.
but eventually vm can't login.  used serial console, pvdisplay showed nothing.
