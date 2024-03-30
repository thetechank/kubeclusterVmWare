#! /bin/bash
set -e
POD_CIDR=$1
SERVICE_CIDR=$2

NODENAME=$(hostname -s)


export PRIMARY_IP=$(ip route | grep default | awk '{ print $9 }')

sudo kubeadm init \
  --pod-network-cidr $POD_CIDR \
  --service-cidr $SERVICE_CIDR \
  --apiserver-advertise-address $PRIMARY_IP

echo "Kubeadm Init Complete"
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id vagrant -u):$(id vagrant -g) /home/vagrant/.kube/config
#chmod 600 /home/vagrant/.kube/config
echo "Copied kube config at master node => .kube/config"

echo "Start Flannel Install"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
echo "Flannel install complete"

# Save Configs to shared /Vagrant location
# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.
config_path="/vagrant/configs"
if [[ -d $config_path ]]
then
   echo "Removing old configs"
   rm -rf $config_path/*
else
   echo "Creating Configs"
   sudo mkdir -p /vagrant/configs/.ssh
fi
echo "Created folder /vagrant/configs"

cp -i /etc/kubernetes/admin.conf /vagrant/configs/config
touch /vagrant/configs/join.sh
chmod +x /vagrant/configs/join.sh 
echo "Created and copied join.sh at /vagrant/configs/join.sh"
# Generete kubeadm join token
sudo kubeadm token create --print-join-command > /vagrant/configs/join.sh 2>/dev/null
echo "Genereted kubeadm join token command" 
