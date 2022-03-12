 #!/bin/bash


 brew  install --cask virtualbox
 brew  install --cask vagrant
 brew  install --cask vagrant-manager
 #vagrant box add ubuntu/xenial64 http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box
 vagrant up
 OUTPUT= vagrant global-status | grep manager
 #vagrant ssh $OUTPUT  -- -t '
 vagrant ssh 1399da8  -- -t '
 git clone https://github.com/jcwimer/docker-swarm-autoscaler.git
 cd docker-swarm-autoscaler
 docker stack deploy -c swarm-autoscaler-stack.yml autoscaler
 cd /home/vagrant/example-voting-app
 docker stack deploy --compose-file docker-stack-01.yml vote

'


