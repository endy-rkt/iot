#! /bin/sh

#install dep
apk update && apk upgrade
apk add --no-cache curl linux-lts

# 2. edit OpenRC config
vi /etc/rc.conf
# uncomment/set:
rc_cgroup_mode="unified"


# 3. re-enable the cgroups service at boot
rc-update add cgroups boot
rc-service cgroups stop 2>/dev/null

reboot

#load kernel module 
modprobe overlay
curl -sfL https://get.k3s.io | sh -