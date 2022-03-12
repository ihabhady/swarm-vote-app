# swarm-vote-app
This app provisions compelete docker swarm catvs dogs app enviorment with one manager node and 2 workers. The provisioning constructs the nodes and joins docker swarm using vagrant.
Steps to deploy:
1. Download the two files anywhere.
2. Run app.sh , Note: Donot change the vagrant file loaction keep it beside the app.sh

What happens in the background:
The app.sh download vagrant , virtual box and docker pacakges. Once all downloaded the swarm cluster is consturcted and then the vagrant file starts to assign the roles of managers and workers. The next step we take the deploy stack for the voting app and we add labels
"
deploy:
  labels:
    - "swarm.autoscaler=true"
 "
 Beside some selected services that needs to be scaled. The auto scaling mechanism is borrowed from https://github.com/jcwimer/docker-swarm-autoscaler where it depends on promethus and node exporters for mointioring purposes and once the threshold is hit it scales the services using this sh file https://github.com/jcwimer/docker-swarm-autoscaler/blob/master/docker-swarm-autoscaler/auto-scale.sh. Moreover we added the md5 password of the user in the deploy-stack-01.yml to not expose the plaintext password.
 Once the file writing completed we start using vagrant ssh to access the manager node to deploy the autoscaler and the voting app.
 
