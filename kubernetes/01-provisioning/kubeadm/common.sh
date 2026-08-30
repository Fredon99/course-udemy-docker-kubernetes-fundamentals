#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

K8S_MINOR="v1.37"
PRIVATE_NET_REGEX='^192\.168\.56\.'

log() { echo "[common] $*"; }
die() { echo "[common] ERRO: $*" >&2; exit 1; }

retry() {
  local attempts=5
  local delay=5
  local n=1
  until "$@"; do
    if (( n >= attempts )); then
      return 1
    fi
    echo "[common] tentativa $n falhou: $*; tentando novamente..."
    sleep "$delay"
    n=$((n + 1))
  done
}

log "Detectando IP privado do node..."
NODE_IP="$(ip -4 -o addr show | awk '$4 ~ /^192\.168\.56\./ {split($4,a,"/"); print a[1]; exit}')"
[[ -n "$NODE_IP" ]] || die "não encontrei endereço 192.168.56.x na VM"
log "Node IP: $NODE_IP"

log "Desabilitando swap..."
swapoff -a || true
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab || true

log "Carregando módulos de kernel..."
cat > /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

log "Configurando sysctl para Kubernetes/CNI..."
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null

log "Instalando dependências..."
retry apt-get update -y
retry apt-get install -y ca-certificates curl gpg apt-transport-https
install -m 0755 -d /etc/apt/keyrings

log "Configurando repositório do Docker/containerd..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable
EOF
retry apt-get update -y
retry apt-get install -y containerd.io

log "Gerando configuração do containerd compatível com a versão instalada..."
mkdir -p /etc/containerd/conf.d
containerd config default > /etc/containerd/config.toml

# Kubernetes com cgroup v2 deve usar systemd no kubelet e no runtime.
# Funciona com a configuração gerada pelo próprio containerd 1.x/2.x.
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

grep -q 'SystemdCgroup = true' /etc/containerd/config.toml \
  || die "não consegui habilitar SystemdCgroup no containerd"

log "Validando configuração do containerd..."
containerd config dump >/dev/null
systemctl enable containerd >/dev/null 2>&1 || true
systemctl restart containerd
systemctl is-active --quiet containerd || die "containerd não ficou ativo"

log "Configurando repositório Kubernetes ${K8S_MINOR}..."
rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat > /etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /
EOF
retry apt-get update -y
retry apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl >/dev/null

# VirtualBox normalmente cria uma interface NAT 10.0.2.15 em todas as VMs.
# Forçamos o kubelet a publicar o IP único da rede privada.
log "Forçando kubelet a usar $NODE_IP como node-ip..."
cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}
EOF

systemctl enable kubelet >/dev/null 2>&1 || true
systemctl restart kubelet || true

log "Versões instaladas:"
containerd --version
kubeadm version -o short
kubelet --version

log "Configuração comum concluída."
