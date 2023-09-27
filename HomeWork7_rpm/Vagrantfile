# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provision "file", source: "./nginx.spec", destination: "~/nginx.spec"
  config.vm.provision "file", source: "./default.conf", destination: "~/default.conf"
  config.vm.provision "file", source: "./otus.repo", destination: "~/otus.repo"

  config.vm.provision "shell", inline: <<-SHELL
     sudo -i
     yum install -y redhat-lsblcore wget rpmdevtools rpm-build createrepo yum-utils gcc zlib-devel openssl-devel
     wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.20.2-1.el7.ngx.src.rpm
     rpm -i nginx-1.20.2-1.el7.ngx.src.rpm
     wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
     unzip OpenSSL_1_1_1-stable.zip
     yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
     cp -f /home/vagrant/nginx.spec /root/rpmbuild/SPECS/nginx.spec
     rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
     yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm 
     systemctl start nginx
     mkdir /usr/share/nginx/html/repo
     cp -f /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
     wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/7/x86_64/percona-orchestrator-3.2.6-2.el7.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el7.x86_64.rpm
     createrepo /usr/share/nginx/html/repo/
     cp -f /home/vagrant/default.conf /etc/nginx/conf.d/default.conf
     nginx -s reload
     cp -f /home/vagrant/otus.repo /etc/yum.repos.d/otus.repo

   SHELL

  end
