
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



restarted as c5ad.16xlarge
file system /var/swapfile persisted and booted ok.
see two new nvme devices

lsblk -p

nvme0n1      259:1    0   430G  0 disk
├─nvme0n1p1  259:2    0 429.9G  0 part /
├─nvme0n1p14 259:3    0     4M  0 part
└─nvme0n1p15 259:4    0   106M  0 part /boot/efi
nvme1n1      259:0    0   1.1T  0 disk
nvme2n1      259:5    0   1.1T  0 disk


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


can probably do  (assuming device path is the same every time)
but run it once and only once!
bash -x ~/tin/enable_swap_ephemeral.txt

