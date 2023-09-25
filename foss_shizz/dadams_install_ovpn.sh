#!/usr/bin/env bash

print_bold() {
    echo "$(tput bold)*****$@*****$(tput sgr0)"
}
export -f print_bold

CICDMODE=$1

# Update APT and Install OpenVPN
print_bold "Installing OpenVPN"
sudo apt update
sudo apt install openvpn -y




# Attempt to find the OVPN File.
# If no OVPN file is found, the script will exit with the Code 1.
# If more than one OVPN file is found, alert the user and exit with the error
# code 2.
if [[ "${CICDMODE}" == "true" ]]; then
   print_bold "Checking for OpenVPN File in Repo Root"
   ovpnpath=($(find . -maxdepth 1 -type f -name "*.ovpn"))
elif [[ "${CICDMODE}" != "true" ]]; then
   print_bold "Checking for OpenVPN File in ${USER}'s Home Directory."
   ovpnpath=($(find ${HOME} -maxdepth 1 -type f -name "*.ovpn"))
fi

CHECK_NUM=${#ovpnpath[@]}
if [[ -z ${ovpnpath} ]]; then
   print_bold "No OVPN File Found. Exiting."
   exit 1
fi
if [[ ${CHECK_NUM} -gt 1 ]]; then
   print_bold "More than one OVPN file found. Please move or delete additional OVPN files and rerun setup."
   for x in ${ovpnpath[@]}; do echo $x; done
   exit 2
fi

print_bold "OVPN File found at ${ovpnpath}."
print_bold "Copying to /etc/openvpn"

# Copy OVPN File to
target=$(echo $ovpnpath |  sed -e 's/\//\t/g' -e 's/\.ovpn/\.conf/' | awk {'print $3'})
sudo cp $ovpnpath /etc/openvpn/${target}

# Uncomment this block if setting up server as VPN Router.
##################################################################################################
# # Activate Port Forwarding for IPv4 and IPv6
# sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# sudo sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
# sudo sysctl -p
##################################################################################################

# Reload System Control Daemon
sudo systemctl daemon-reload

# Restart OpenVPN Service
print_bold "Restarting OpenVPN Service"
sudo systemctl restart openvpn

# Wait for Tun0
if [[ "${CICDMODE}" == "true" ]]; then
    print_bold "Skipping TUN and Sleep Commands."
    exit
else
   print_bold "Waiting for tun0"
   sleep 1s
   TUN=$(sudo ifconfig | grep tun0 | awk '{print $1}')
   while [[ -z ${TUN} ]]
   do
      print_bold "Still Waiting for tun0"
      sleep 2s
      TUN=$(sudo ifconfig | grep tun0 | awk '{print $1}')
   done
fi


# Uncomment this block if setting up server as VPN Router.
##################################################################################################
# # Set IPTABLES rules to allow port forwarding and NAT.
# print_bold "Adding Port Forward Rules."
# sudo iptables -A FORWARD -j ACCEPT
# print_bold "Setting NAT Routes"
# sudo apt install iptables-persistent -y
# export IF=`ip route | grep default | awk '{print $5}'`
# sudo iptables -t nat -A POSTROUTING -o $IF -j MASQUERADE
# sudo iptables-save | sudo tee /etc/iptables/rules.v4
# sudo ip6tables -t nat -A POSTROUTING -o $IF -j MASQUERADE
# sudo ip6tables-save | sudo tee /etc/iptables/rules.v6
##################################################################################################


# Check for OpenVPN Running Status
tunIP=$(sudo ifconfig | grep -A1 tun0 | awk '/inet/ {print $2}')
status=$(sudo systemctl --type=service --state=active | grep -i openvpn@ | awk {'print $2'})
if [[ "${status}" == "loaded" ]] ; then
   print_bold "OpenVPN Daemon Loaded. Please test by running 'ping ${tunIP}'"
   exit 0
else
    print_bold "OpenVPN Service Not Running. Please Check System Configuration and Try Running This Script Again."
    exit 1
fi
