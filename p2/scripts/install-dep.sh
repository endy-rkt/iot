#!/bin/sh
echo "installing package dependancy"

apk update && apk upgrade
apk add --no-cache curl linux-lts iptables ip6tables

# set cgroup version to v2
echo 'rc_cgroup_mode="unified"' >> /etc/rc.conf

# re-enable the cgroups service at boot
rc-update add cgroups boot
rc-service cgroups stop 2>/dev/null
