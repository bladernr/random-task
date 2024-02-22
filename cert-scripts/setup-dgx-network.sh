#!/bin/bash
#
# DGX Network Setup
#
# This script sets up the network on the DGX systems that are configured with
# back-to-back network devices.
#

SERVER_IFACE=""
CLIENT_IFACE=""
SECURE_ID=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--server) SERVER_IFACE="$2"; shift ;;
        -c|--client) CLIENT_IFACE="$2"; shift ;;
	-i|--secureid) SECURE_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if variables were set
if [[ -z "$SERVER_IFACE" ]] || [[ -z "$CLIENT_IFACE" ]]; then
    echo "Usage: $0 -s SERVER_IFACE -c CLIENT_IFACE [ -i SECURE_ID]"
    exit 1
fi

SERVER_IP="192.168.5.1"
CLIENT_IP="192.168.5.2"

export $SERVER_IFACE
export $SERVER_IP
export $CLIENT_IFACE
export $CLIENT_IP

echo "Setting up network interfaces..."
echo "Server: $SERVER_IFACE ($SERVER_IP)"
echo "Client: $CLIENT_IFACE ($CLIENT_IP)"

# Determine NUMA nodes for each NIC
SERVER_NUMA_NODE=$(cat /sys/class/net/$SERVER_IFACE/device/numa_node)
CLIENT_NUMA_NODE=$(cat /sys/class/net/$CLIENT_IFACE/device/numa_node)

echo "Getting NUMA nodes for each NIC..."
echo "Server NUMA node: $SERVER_NUMA_NODE"
echo "Client NUMA node: $CLIENT_NUMA_NODE"

# Create the net namespace and add the server NIC to that namespace
echo "Creating network namespace for server..."
sudo ip netns add server
sudo ip netns exec server ip link set lo up
sudo ip link set $SERVER_IFACE netns server
sudo ip netns exec server ip addr add $SERVER_IP/24 dev $SERVER_IFACE
sudo ip netns exec server ip link set $SERVER_IFACE up
sudo ip netns exec server ip link set $SERVER_IFACE mtu 9000
sudo ip netns exec server ip link show $SERVER_IFACE

# Set up the client NIC
echo "Setting up client NIC..."
sudo ip addr add $CLIENT_IP/24 dev $CLIENT_IFACE
sudo ip link set $CLIENT_IFACE up
sudo ip link set $CLIENT_IFACE mtu 9000
sudo ip link show $CLIENT_IFACE

sudo add-apt-repository -y -qq ppa:checkbox-dev/beta
sudo apt-get -y -qq install canonical-certification-server certification-tools

# Set up iperf on the server interface
echo "Setting up iperf on server interface"
sudo ip netns exec server start-iperf3 -a $SERVER_IP -n 15

echo "Setting up config file..."
CONFIG_FILE="/etc/xdg/canonical-certification.conf"
sudo sed -i 's/^#\[\(transport:c3\)\]/[\1]/' "$CONFIG_FILE"
sudo sed -i "/^#secure_id = /c\secure_id = $SECURE_ID" "$CONFIG_FILE"
sudo sed -i "/^#TEST_TARGET_IPERF /c\TEST_TARGET_IPERF = $SERVER_IP" "$CONFIG_FILE"

echo "Network setup complete."
