#!/usr/bin/env bash
set -euo pipefail

log() { echo "[worker] $*"; }
die() { echo "[worker] ERRO: $*" >&2; exit 1; }

NODE_NAME="$(hostname -s)"
NODE_IP="$(ip -4 -o addr show | awk '$4 ~ /^192\.168\.56\./ {split($4,a,"/"); print a[1]; exit}')"
[[ -n "$NODE_IP" ]] || die "não encontrei endereço 192.168.56.x"

if [[ -f /etc/kubernetes/kubelet.conf ]]; then
  log "$NODE_NAME já está associado ao cluster; pulando kubeadm join."
  systemctl restart containerd
  systemctl restart kubelet
  exit 0
fi

log "Aguardando comando de join criado pelo master..."
for _ in $(seq 1 120); do
  if [[ -s /vagrant/join-command.sh ]]; then
    break
  fi
  sleep 5
done
[[ -s /vagrant/join-command.sh ]] || die "join-command.sh não apareceu"

log "Entrando no cluster como ${NODE_NAME} (${NODE_IP})..."
# /etc/default/kubelet já contém --node-ip=<IP privado>, configurado em common.sh.
bash /vagrant/join-command.sh

# Garante nova negociação do cgroup driver após o join.
systemctl restart kubelet
systemctl is-active --quiet kubelet || die "kubelet não ficou ativo"

log "$NODE_NAME associado ao cluster."
