#! /bin/bash
set -e

RUNTIME=$1
RUNTIME_VERSION=$2

# disable swap 
sudo swapoff -a
sudo cp /etc/fstab /etc/fstab.bak
sed -i -e 's/\/swap/#\/swap/' /etc/fstab
echo "Disabled swap and keeps the swaf off during reboot"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay
echo "kernel settings setup required sysctl params, these persist across reboots"

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
echo "Required System Variable set to 1"

sudo apt-get update >/dev/null 2>&1

if [[ "$RUNTIME" = "containerd" ]]
then
  sudo apt-get install -y containerd

  sudo mkdir -p /etc/containerd
  sudo containerd config default > /etc/containerd/config.toml
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
  cat /etc/containerd/config.toml

  echo "Systemd set as Cgroup driver"

  sudo systemctl restart containerd
  sudo systemctl status containerd.service

  echo "$RUNTIME Runtime Configured Successfully"

fi

# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "Added Kubernetes apt repository"

#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "Installed kubelet kubectl kubeadm"

#Configure crictl in case we need it to examine running containers
sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock

export PRIMARY_IP=$(ip route | grep default | awk '{ print $9 }')

cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip ${PRIMARY_IP}'
EOF