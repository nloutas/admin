# terraform demo for bastion and reverse NAT
=========================================================================

     
## AWS console: resource verification 

* Route53 entry for dev-nikos-demo.dev.emnify.io.

https://console.aws.amazon.com/route53/home?region=eu-west-1#resource-record-sets:Z2IDR9QI6V4E6N

[filter by "dev-nikos"]

* Bastion and "private demo" EC2 instances

https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:search=bastion;sort=tag:Name

* Reverse NAT EC2 instance

https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:search=NAT%20instance;sort=tag:Name

* Security Groups

https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#SecurityGroups:search=bastion;sort=tag:Name

------------------------------------------------
#### run Ansible playbook to copy terraform PEM key file to bastion instance

      ansible-playbook  -i ansible/hosts  --become-user ubuntu  ansible/main.yml 
 

------------------------------------------------
## CLI verification

#### bastion instance 
- connect to bastion

    ssh  -i ~/.ec2/terraform.pem ubuntu@dev-nikos-bastion.dev.emnify.io

- check terraform key 

    ls -l ~/.ssh/terraform.pem

- connect from bastion to EC2 instance in private subnet

    ssh  -i ~/.ssh/terraform.pem  ubuntu@10.188.2.89

#### reverse NAT instance

- connect from office host to DW redshift 

    psql -h dev-nikos-demo.dev.emnify.io  -U bi  -d dw -p 5439


- login

    ssh  -i ~/.ec2/terraform.pem ubuntu@dev-nikos-demo.dev.emnify.io

- check IP forwarding is enabled

    sudo sysctl -p

- check iptables forwarding rules

    sudo iptables-save

- display user-data applied at initial boot  

    curl http://169.254.169.254/latest/user-data/

