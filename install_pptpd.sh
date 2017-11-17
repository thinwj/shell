#!/bin/bash

if [ $# -ne 7 ] ; then
  echo "Usage $0 localip remoteip dns1 dns2 username password network/mask"
  echo "$0 10.8.0.1 10.8.0.100-150 8.8.8.8 8.8.4.4 vpn_user vpn_passwd 10.8.0.0/24"
  exit 1
fi

# install pptp
which pptpd > /dev/null
if [ "$?" != "0" ]; then
  yum -y install ppp pptpd
fi

# config local ip and remote ip
echo "localip $1" >> /etc/pptpd.conf
echo "remoteip $2" >> /etc/pptpd.conf

# config dns
sed -i 's/^#ms-dns 10.0.0.1/ms-dns '$3'/' /etc/ppp/options.pptpd
sed -i 's/^#ms-dns 10.0.0.2/ms-dns '$4'/' /etc/ppp/options.pptpd

# config vpn username and password
echo "$5 pptpd $6 *" >> /etc/ppp/chap-secrets

# config network forward
sysctl -w net.ipv4.ip_forward=1
sed -n 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/p' /etc/sysctl.conf
iptable_num=`iptables -nL --line-number | awk '/dpt:22/ {print $1+1}'`
iptables -I INPUT $iptable_num -p tcp -m state --state NEW -m tcp --dport 1723 -j ACCEPT
iptables -F FORWARD
iptables -A FORWARD -j ACCEPT
iptables -t nat -A POSTROUTING -s $7 -o eth0 -j MASQUERADE

# start pptpd service
service pptpd start
chkconfig pptpd on
