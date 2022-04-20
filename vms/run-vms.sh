#!/bin/bash
function setup_network()
{
    sudo brctl addbr vmbr0
    sudo ip tuntap add tap0 mode tap
    sudo ip tuntap add tap1 mode tap
    sudo brctl addif vmbr0 tap0    
    sudo brctl addif vmbr0 tap1
    sudo ip link set up dev tap0
    sudo ip link set up dev tap1
    sudo ip link set up dev vmbr0    
}

qemu-system-x86_64 -smp 2 -enable-kvm -m 2048 \
		    -hda ./DebianExploited/DebianExploited.vmdk \
		    -boot once=c \
		    -net nic,macaddr=00:aa:bb:cc:dd:ee \
		    -net tap,ifname=tap0,script=no \
		    -name "DebianExploited" &

qemu-system-x86_64 -smp 2 -enable-kvm -m 2048 \
		    -hda ./DebianExploiter/DebianExploiter.vmdk \
		    -boot once=c \
		    -net nic,macaddr=00:aa:bb:cc:dd:ef \
		    -net tap,ifname=tap1,script=no \
		    -name "DebianExploiter" &


while [ $(jobs -pr | wc -l) -ne "0" ]
do
    sleep 3
done

echo "Done."
