#!/bin/sh
apt-get update
apt-get install -y docker.io
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
cat <<EOF >/etc/kubernetes/kubeadm.conf
piVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
cloudProvider: azure
kubernetesVersion: 1.10.2
apiServerExtraArgs:
  cloud-provider: azure
  cloud-config: /etc/kubernetes/cloud-config
controllerManagerExtraArgs:
  cloud-provider: azure
  cloud-config: /etc/kubernetes/cloud-config
networking:
  podSubnet: 10.244.0.0/16
EOF
sed -i -E 's/(.*)KUBELET_KUBECONFIG_ARGS=(.*)$/\1KUBELET_KUBECONFIG_ARGS=--cloud-provider=azure --cloud-config=\/etc\/kubernetes\/cloud-config \2/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
/sbin/sysctl -p /etc/sysctl.conf