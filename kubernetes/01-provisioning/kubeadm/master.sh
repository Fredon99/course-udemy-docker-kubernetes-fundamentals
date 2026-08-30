#!/usr/bin/env bash
set -euo pipefail

FLANNEL_VERSION="v0.28.8"
FLANNEL_MANIFEST="https://github.com/flannel-io/flannel/releases/download/${FLANNEL_VERSION}/kube-flannel.yml"

log() { echo "[master] $*"; }
die() { echo "[master] ERRO: $*" >&2; exit 1; }

NODE_IP="$(ip -4 -o addr show | awk '$4 ~ /^192\.168\.56\./ {split($4,a,"/"); print a[1]; exit}')"
[[ -n "$NODE_IP" ]] || die "não encontrei endereço 192.168.56.x"

# Evita worker usar um comando de join antigo após vagrant destroy/up.
rm -f /vagrant/join-command.sh

if [[ ! -f /etc/kubernetes/admin.conf ]]; then
  log "Inicializando control-plane em ${NODE_IP}..."

  cat > /root/kubeadm-config.yml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${NODE_IP}
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
  kubeletExtraArgs:
    - name: node-ip
      value: ${NODE_IP}
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
networking:
  podSubnet: 10.244.0.0/16
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

  kubeadm init --config /root/kubeadm-config.yml
else
  log "Cluster já inicializado; pulando kubeadm init."
fi

export KUBECONFIG=/etc/kubernetes/admin.conf

log "Configurando kubectl para o usuário vagrant..."
install -d -m 0700 -o vagrant -g vagrant /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 0600 /home/vagrant/.kube/config

log "Instalando Flannel ${FLANNEL_VERSION}..."
kubectl apply -f "$FLANNEL_MANIFEST"

# CORREÇÃO PARA VAGRANT/VIRTUALBOX:
# A interface NAT costuma ser 10.0.2.15 em todas as VMs. Sem esta opção,
# o Flannel pode registrar master e workers com o MESMO IP.
# O regex seleciona o endereço da rede privada 192.168.56.x independentemente
# do nome da interface (enp0s8, eth1 etc.).
log "Forçando Flannel a usar a rede privada 192.168.56.x..."
kubectl -n kube-flannel patch daemonset kube-flannel-ds --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--iface-regex=^192\\.168\\.56\\."}
]'

log "Reiniciando kubelet após configuração final do runtime..."
systemctl restart kubelet

log "Aguardando o control-plane ficar Ready..."
kubectl wait --for=condition=Ready node/master-1 --timeout=300s

log "Gerando novo comando de join para os workers..."
(
  umask 022
  kubeadm token create --print-join-command > /vagrant/join-command.sh.tmp
  echo ' --cri-socket unix:///run/containerd/containerd.sock' >> /vagrant/join-command.sh.tmp
  tr -d '\n' < /vagrant/join-command.sh.tmp > /vagrant/join-command.sh
  echo >> /vagrant/join-command.sh
  rm -f /vagrant/join-command.sh.tmp
  chmod 0755 /vagrant/join-command.sh
)

log "Control-plane pronto."
kubectl get nodes -o wide
kubectl get pods -n kube-flannel -o wide
