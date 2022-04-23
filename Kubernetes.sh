#!/bin/bash
##############################################################################################
#					HOW TO INSTALL KUBERNETES, MASTER NODE									 #
#				CREATE BY: Majid Mortazavi, Co: Pars Azarakhsh								 #
#									V: 0.1													 #
##############################################################################################
#Install prerequisites:
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install curl apt-transport-https

#Add Kuber repo:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Install kubernetes:
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl

#Check:
kubectl version --client && kubeadm version

#Swap must be off:
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

#######################Install docker:################################

#Install prerequisites:
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

#Add docker repo:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Install docker:
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systectl enable docker
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#Initialize kuber as master node:
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#Finish installing kuber: (as a sudoer user)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#######################Add flunnel:################################

#Apply flunnel: (*****Better way is add first worker node, then add flunnel*****)
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

#If firewall is active:
sudo ufw status
sudo ufw allow 6443
