#! /bin/bash
set -e

mkdir -p $HOME/.kube
sudo cp -i /vagrant/configs/config $HOME/.kube/
sudo chown $(id vagrant -u):$(id vagrant -g) $HOME/.kube/config
echo "Copied from /vagrant/configs/config to ${HOME}.kube/ " 


ssh-keygen -q -t rsa -N '' -f $HOME/.ssh/id_rsa <<<y
echo "Generated KeyPair"
sudo cp ~/.ssh/id_rsa.pub /vagrant/configs/.ssh/
