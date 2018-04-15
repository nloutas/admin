# Setup of a new workstation

Tested on a fresh installation of Ubuntu 16.04 LTS with upgraded packages 

    sudo add-apt-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install git ansible

Generate RSA SSH key, if you need to: 
    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub 

Allow access for the public ssh key on github -> settings -> SSH and PGP keys
Then clone repo:
    git clone git@github.com:nloutas/admin.git
    cd admin

Execute workstation playbook:

    ansible-playbook workstation.yml -i hosts -c local  --ask-sudo-pass


# Post installation

After the installation you may have to log off and log in again to have every setting available.

## AWS CLI

run following command to configure the aws cli:

    aws configure

Settings:

    AWS Access Key ID [None]: {{your_access_key_id}}
    AWS Secret Access Key [None]: {{your_secret_access_key}}
    Default region name [None]: eu-west-1
    Default output format [None]: table

## Eclipse

- Download Eclipse Code Style: [google-java-format](https://github.com/google/google-java-format#eclipse)
- Import in _Preferences_ > _Java_ > _Code Style_ > _Formatter_
- Download import order: [emnify.importorder](https://s3-eu-west-1.amazonaws.com/emnify-dev-software/eclipse/emnify.importorder)
- Import in _Preferences_ > _Java_ > _Code Style_ > _Organize Imports_
- enable autoformatting of edited lines on save:
  _Preferences_ > _Java_ > _Editor_ > _Save Actions_:
  - [X] Perform the selected actions on save
    - [X] Format source code
      - [ ] Format all lines
      - [X] Format edited lines
    - [X] Organize imports


## Installed software

* java 8
* maven 3
* nginx
* docker
* vagrant
* virtualbox
* postman
* flyway
* eclipse
* IntelliJ
* vim
* wireshark
* mysql
* mysql-workbench
* terminator
* meld
* awscli

