# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
    :box_name => "centos/7",
    :vm_name => "inetRouter",
    :net => [
      {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.248", virtualbox__intnet: "router-net"}, # /29
      {ip: '192.168.56.101', adapter: 3}
    ]
  },

  :inetRouter2 => {
    :box_name => "centos/7",
    :vm_name => "inetRouter2",
    :net => [
      {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.248", virtualbox__intnet: "router-net"}, # /29
      {ip: '192.168.56.102', adapter: 3}
    ]
  },

  :centralRouter => {
    :box_name => "centos/7",
    :vm_name => "centralRouter",
    :net => [
      {ip: '192.168.255.3', adapter: 2, netmask: "255.255.255.248", virtualbox__intnet: "router-net"},# /29
      {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "c-net"},   # /24
      {ip: '192.168.56.103', adapter: 4}
    ]
  },
  
  :centralServer => {
    :box_name => "centos/7",
    :vm_name => "centralServer",
    :net => [
      {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "c-net"},     # /24
      {ip: '192.168.56.104', adapter: 3}
    ]
  },
}

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true
  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s

      boxconfig[:net].each do |ipconf|
        box.vm.network "private_network", ipconf
      end
      
      if boxconfig.key?(:public)
        box.vm.network "public_network", boxconfig[:public]
      end

      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
      SHELL

      case boxname.to_s
      # when "inetRouter"
      #   box.vm.provision "shell", run: "always", inline: <<-SHELL
      #     sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service
      #     SHELL
      when "inetRouter2"
        box.vm.network "forwarded_port", guest:8080, host: 8080
      when "centralServer"
        box.vm.provision "ansible" do |ansible|
          ansible.playbook = "ansible/provision.yml"
          ansible.inventory_path = "ansible/hosts"
          ansible.host_key_checking = "false"
          ansible.limit = "all"
        end
      end
    end
  end
 
end
