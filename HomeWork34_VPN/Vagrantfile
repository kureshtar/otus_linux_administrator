# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :server => {
    :box_name => "centos/7",
    :vm_name => "server",
    :net => [
      {ip: '192.168.10.10', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "net"},
      {ip: '192.168.56.101', adapter: 3}
    ]
  },

  :client => {
    :box_name => "centos/7",
    :vm_name => "client",
    :net => [
      {ip: '192.168.10.20', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "net"},
      {ip: '192.168.56.102', adapter: 3}
    ]
  },

  :ras => {
    :box_name => "centos/7",
    :vm_name => "ras",
    :net => [
      {ip: '192.168.56.103', adapter: 3}
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
      when "ras"
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
