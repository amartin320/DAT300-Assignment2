#!/bin/bash
# Author: Aitor Martin Rodriguez (University of Stavanger)

# Check input arguments and provide usage help
if [ $(($# % 2)) -eq 1 ] || [ $# -eq 0 ] ; then
	echo "missing arguments."
	echo "usage: ./link_emulation.sh <interface1> <interface2> [parameters and values]"
	echo "example: ./link_emulation.sh eth1 eth2 delay 20ms loss 0.1%"
	echo "parameters: delay(ms), rate(Mbit), loss(%), limit(packets)"
	echo "exiting..."
	exit
fi

# Remove previously configured queues
echo "Removing existing queues..."

INTERFACE="$(sudo tc qdisc show | grep netem | awk '{print $5}' | head -n 1 | head -c -1)"
while [ -n "$INTERFACE" ]; do
	echo sudo tc qdisc del dev $INTERFACE root
	sudo tc qdisc del dev $INTERFACE root
	INTERFACE="$(sudo tc qdisc show | grep netem | awk '{print $5}' | head -n 1 | head -c -1)"
done

# Set up the tc commands for the new queues in the specified interfaces
echo "Configuring new queues in $1 and $2..."

queue1="sudo tc qdisc add dev $1 root netem"
queue2="sudo tc qdisc add dev $2 root netem"

for ((i=3; i < $#; i+= 2)); do
	parameter="${@:i:1}"
	value="${@:i+1:1}"
	
	queue1="$queue1 $parameter $value"
	queue2="$queue2 $parameter $value"
done

# Print and apply the new queues with tc

echo $queue1
$queue1

echo $queue2
$queue2
