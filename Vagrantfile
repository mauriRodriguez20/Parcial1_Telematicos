Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # VM1 - DNS Maestro
  config.vm.define "maestro" do |m|
    m.vm.hostname = "maestro.empresa.local"
    m.vm.network "private_network", ip: "192.168.56.10"

    m.vm.provider "virtualbox" do |vb|
      vb.name = "DNS-Maestro"
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  # VM2 - DNS Esclavo
  config.vm.define "esclavo" do |e|
    e.vm.hostname = "esclavo.empresa.local"
    e.vm.network "private_network", ip: "192.168.56.11"

    e.vm.provider "virtualbox" do |vb|
      vb.name = "DNS-Esclavo"
      vb.memory = 1024
      vb.cpus = 1
    end
  end
end