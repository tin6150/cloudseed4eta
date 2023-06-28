#!/bin/bash

    echo ""
    echo "This script creates swap partitions out of aws ephemeral storage,"
    echo "which includes destructive operations to partition the ssd"
    echo " ** !run this only once after boot only! ** "
    echo ""


## conditions for mdt
# Disk /dev/nvme0n1: 36 GiB, 38654705664 bytes, 75497472 sectors			## os
# Disk /dev/nvme1n1: 310 GiB, 332859965440 bytes, 650117120 sectors			## /mnt/data1

# Disk /dev/nvme2n1: 558.79 GiB, 600000000000 bytes, 1171875000 sectors		## ephemeral
# Disk /dev/nvme3n1: 558.79 GiB, 600000000000 bytes, 1171875000 sectors
# Disk /dev/nvme4n1: 558.79 GiB, 600000000000 bytes, 1171875000 sectors
# Disk /dev/nvme5n1: 558.79 GiB, 600000000000 bytes, 1171875000 sectors

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
    # sudo swapoff /var/swapfile
    echo ""
    sudo swapon -s

