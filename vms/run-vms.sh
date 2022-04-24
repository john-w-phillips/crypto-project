#!/bin/bash

ARGS=$(getopt -o "v" \
	      -l "nosudo,exploiter-image:,exploited-image:,--qemu:,help" -- "$@")
eval set -- "$ARGS"

SUDO=sudo
EXPLOITED=DebianExploited/DebianExploited.vmdk
EXPLOITER=DebianExploiter/DebianExploiter.vmdk
QEMU=qemu-system-x86_64
function usage()
{
    cat <<_EOF_
Usage:
       ./run-vms [OPTIONS]
       OPTIONS:
       --exploiter-image	Location of the 'exploiter' HD image in the filesystem.
       --exploited-image	Location of the 'exploited' HD image in the filesystem.
       --nosudo			Do not use sudo for network configuration (only turn this on if you're root).
       --qemu			Location of the qemu binary (defaults to ${QEMU})
       --help			Print this help.

 This script will first set up a basic network configuration for two
VMS that emulates two machines being hooked up to a single switch (two
machines on a LAN). This step requires root/sudo access.  The VMs are
configured to have static IP addresses. Then it boots the machines
using the ${QEMU} command.

_EOF_

}
while true
do
    case "$1" in
	-v| --verbose)
	    set -x
	    shift
	    ;;
	--exploiter-image)
	    EXPLOITER=$2
	    shift 2
	    ;;
	--exploited-image)
	    EXPLOITED=$2
	    shift 2
	    ;;
	--nosudo)
	    SUDO=
	    shift
	    ;;
	--qemu)
	    QEMU=$2
	    shift 2
	    ;;
	--help)
	    usage
	    exit 0
	    ;;
	*) break;
    esac
done

function setup_network()
{
    ${SUDO} brctl addbr vmbr0
    ${SUDO} ip tuntap add tap0 mode tap
    ${SUDO} ip tuntap add tap1 mode tap
    ${SUDO} brctl addif vmbr0 tap0    
    ${SUDO} brctl addif vmbr0 tap1
    ${SUDO} ip link set up dev tap0
    ${SUDO} ip link set up dev tap1
    ${SUDO} ip link set up dev vmbr0    
}

function cleanup_network()
{
    ${SUDO} ip link set down dev tap0
    ${SUDO} ip link set down dev tap1
    ${SUDO} ip link del dev tap0
    ${SUDO} ip link del dev tap1
    ${SUDO} ip link set down dev vmbr0
    ${SUDO} ip link del dev vmbr0
}

function test_qemu()
{
    if ! which ${QEMU}>/dev/null
    then
	echo "No QEMU binary (looking for ${QEMU}). Please install qemu or point to it with the --qemu command."
    fi
}

test_qemu
setup_network
# Boot the 'exploited' VM.
echo "Booting exploited VM, HD image at ${EXPLOITED}."
${QEMU} -smp 2 -enable-kvm -m 2048 \
		    -hda "${EXPLOITED}" \
		    -boot once=c \
		    -net nic,macaddr=00:aa:bb:cc:dd:ee \
		    -net tap,ifname=tap0,script=no \
		    -name "DebianExploited" &

# Boot the 'exploiter' VM.
echo "Booting exploited VM, HD image at ${EXPLOITER}."
${QEMU} -smp 2 -enable-kvm -m 2048 \
		    -hda "${EXPLOITER}" \
		    -boot once=c \
		    -net nic,macaddr=00:aa:bb:cc:dd:ef \
		    -net tap,ifname=tap1,script=no \
		    -name "DebianExploiter" &


while [ $(jobs -pr | wc -l) -ne "0" ]
do
    sleep 3
done

echo "Done with experiment, cleaning up network..."
cleanup_network
