#!/usr/bin/env bash
set -euo pipefail

log() { echo "[prepare-vm] $*"; }

log "Configurando /etc/hosts do laboratório..."
cat >> /etc/hosts <<'EOF'
192.168.56.101 master-1
192.168.56.201 worker-1
192.168.56.202 worker-2
EOF

# Remove duplicatas caso o provisionamento seja executado novamente.
awk '!seen[$0]++' /etc/hosts > /tmp/hosts.clean
cat /tmp/hosts.clean > /etc/hosts
rm -f /tmp/hosts.clean

log "Aplicando workaround de DNS para VirtualBox..."
# No ambiente que originou este lab, o NAT do VirtualBox entregava 127.0.0.53
# mas a resolução externa falhava. Mantemos o workaround que funcionou.
systemctl disable --now systemd-resolved >/dev/null 2>&1 || true
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<'EOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
options timeout:2 attempts:3
EOF
chmod 0644 /etc/resolv.conf

log "Validando rede e DNS..."
ping -c 1 -W 5 8.8.8.8 >/dev/null
getent hosts archive.ubuntu.com >/dev/null
getent hosts download.docker.com >/dev/null
getent hosts pkgs.k8s.io >/dev/null

log "VM preparada."
