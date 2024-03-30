#! /bin/bash
set -e

mkdir -p $HOME/.kube
sudo cp -i /vagrant/configs/config $HOME/.kube/
sudo chown $(id vagrant -u):$(id vagrant -g) $HOME/.kube/config
cat /vagrant/configs/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys


# chmod 600 /home/vagrant/.kube/config
# mkdir -p ~/.ssh
# sudo cp -r /vagrant/configs/.ssh ~/
# sudo chown $(id vagrant -u):$(id vagrant -g) ~/.ssh/*
# mkdir -p ~/.ssh
# sudo cp -r /vagrant/configs/.ssh ~/
# sudo chown $(id -u):$(id -g) ~/.ssh/*