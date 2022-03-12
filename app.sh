 #!/bin/bash


 brew  install --cask virtualbox
 brew  install --cask vagrant
 brew  install --cask vagrant-manager
 vagrant box add ubuntu/xenial64 http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box
 vagrant up
 OUTPUT= $(vagrant global-status --prune | grep $BOX_NAME | awk '{print $1}')
 vagrant ssh $OUTPUT  -- -t '
 #vagrant ssh 1399da8  -- -t '
 git clone https://github.com/jcwimer/docker-swarm-autoscaler.git
 cd docker-swarm-autoscaler
 docker stack deploy -c swarm-autoscaler-stack.yml autoscaler
 cd /home/vagrant/example-voting-app
 docker stack deploy --compose-file docker-stack-01.yml vote
  echo "============== scaling up vote app services ====================="
 docker service scale vote_db=1
 docker service scale vote_redis=1
 docker service scale vote_worker=1
 docker service scale vote_visualizer=1
 docker service scale vote_result=1
'


