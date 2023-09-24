#!/bin/bash
yum install nfs-utils -y
systemctl enable firewalld.service --now
firewall-cmd --add-service="mountd" --add-service="rpc-bind" --add-service="nfs3" --permanent
firewall-cmd --reload
systemctl enable nfs --now
mkdir -p /srv/share/upload/server
mkdir -p /srv/share/upload/client
chown -R nfsnobody:nfsnobody /srv/share
chmod -R 0777 /srv/share/upload
echo '/srv/share 192.168.50.11/32(rw,sync,root_squash)' > /etc/exports
exportfs -r
exportfs -s >> /srv/share/upload/server/exportfs.log
systemctl status firewalld.service > /srv/share/upload/server/state-firewalld.log
echo '+++++++++++++++++' >> /srv/share/upload/server/state-firewalld.log
firewall-cmd --list-all >> /srv/share/upload/server/state-firewalld.log
showmount -a 192.168.50.10 >> /srv/share/upload/server/showmount.log
