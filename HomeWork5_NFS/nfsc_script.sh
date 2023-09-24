yum install nfs-utils -y
systemctl enable firewalld.service --now 
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
systemctl status firewalld.service > /mnt/upload/client/state-firewalld.log
echo '+++++++++++++++++' >> /mnt/upload/client/state-firewalld.log
firewall-cmd --list-all >> /mnt/upload/client/state-firewalld.log
mount | grep mnt > /mnt/upload/client/fstab.log
