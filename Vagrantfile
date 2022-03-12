
# -*- mode: ruby -*-
# vi: set ft=ruby :

$git_get = <<SCRIPT
echo "============== Get from GIT ====================="
  sudo apt install git

SCRIPT


$git_vote_App = <<SCRIPT
 echo "============== Install  docker compose ====================="

  sudo apt install git
  git clone https://github.com/dockersamples/example-voting-app.git
  cd example-voting-app


SCRIPT

$autoscaller = <<SCRIPT
 echo "============== autoscale  ====================="

  sudo apt install git
  git clone https://github.com/jcwimer/docker-swarm-autoscaler.git
  cd docker-swarm-autoscaler
  docker stack deploy -c swarm-autoscaler-stack.yml autoscaler


SCRIPT

$install_compose = <<SCRIPT
 echo "============== Install  docker compose ====================="

    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

    chmod +x ~/.docker/cli-plugins/docker-compose
    sudo chown $USER /var/run/docker.sock

SCRIPT



$manager_script = <<SCRIPT
echo "============== Initializing swarm mode ====================="
echo Swarm Init...
sudo docker swarm init --listen-addr 192.168.56.32:2375 --advertise-addr 192.168.56.32:2375
sudo docker swarm join-token --quiet worker > /vagrant/worker_token
SCRIPT

$worker_script = <<SCRIPT
echo "============== Joining swarm cluster as worker ====================="
echo Swarm Join...
sudo docker swarm join --token $(cat /vagrant/worker_token) 192.168.56.32:2375  
SCRIPT

Vagrant.configure('2') do |config|
vm_box = 'ubuntu/xenial64'
config.vm.define :manager, primary: true  do |manager|
    manager.vm.box = vm_box
    manager.vm.box_check_update = true
    manager.vm.network :private_network, ip: "192.168.56.32"
    manager.vm.network :forwarded_port, guest: 8080, host: 1234
    manager.vm.network :forwarded_port, guest: 5000, host: 1233
    manager.vm.hostname = "manager"
    manager.vm.synced_folder ".", "/vagrant"
    manager.vm.provision "shell", inline: $manager_script, privileged: true#,  run: "always"
    manager.vm.provision "shell", privileged: true , inline: $git_vote_App, privileged: true #,  run: "always"
    manager.vm.provision "shell", privileged: true, inline: 
    <<-SHELL
          echo "============== create new stack file ====================="
        sudo apt install git

       cd /home/vagrant/example-voting-app
       #sudo rm -fr docker-stack.yml
       cat>>docker-stack-01.yml<<END_TEXT
version: "3"
services:

  redis:
    image: redis:alpine
    networks:
      - frontend
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
    labels:
      - "swarm.autoscaler=true"
  db:
    image: postgres:9.4
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "md53175bce1d3201d16594cebf9d7eb3f9d"
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]
  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - 5000:80
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure
    labels:
      - "swarm.autoscaler=true"
  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - 5001:80
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    depends_on:
      - db
      - redis
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints: [node.role == manager]
    labels:
      - "swarm.autoscaler=true"

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]

networks:
  frontend:
  backend:

volumes:
  db-data:
END_TEXT
         chmod 777 docker-stack-01.yml
SHELL

    
  manager.vm.provider "virtualbox" do |vb|
    vb.name = "manager"
    vb.memory = "2024"
    vb.cpus="2"
  end
  end
  
  
(3..4).each do |i|
     config.vm.define "worker0#{i}" do |worker|
      worker.vm.box = vm_box
      worker.vm.box_check_update = true
      worker.vm.network :private_network, ip: "192.168.56.3#{i}"
      worker.vm.hostname = "worker0#{i}"
      worker.vm.synced_folder ".", "/vagrant"
      worker.vm.provision "shell", inline: $worker_script, privileged: true  #,  run: "always"
      worker.vm.provider "virtualbox" do |vb|
        vb.name = "worker0#{i}"
        vb.memory = "2024"
        vb.cpus="2"
      end
    end
  end
  

  # Common config
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "1024"
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--vram", "8"]
  end

  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision "shell", inline: <<-SHELL

    echo "provisioning"
    sudo sh -c 'echo "root:root" | sudo chpasswd'
    sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
     apt-get install \
             apt-transport-https \
       ca-certificates \
       curl \
       software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
    apt-get install -y docker-ce-cli 
    apt-get install -y containerd.io
    usermod -aG docker
    usermod -aG docker  ubuntu
    usermod -aG docker vagrant
    usermod -aG docker root
    #apt-get install linux-image-extra-$(uname -r)
    #export DOCKER_HOST=tcp://localhost:2375
   # sudo apt-get install virtualbox-guest-additions-iso

  SHELL

end 



