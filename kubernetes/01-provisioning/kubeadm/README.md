# Kubernetes com kubeadm + Vagrant + VirtualBox

Este laboratório cria automaticamente:

- `master-1` — `192.168.56.101`
- `worker-1` — `192.168.56.201`
- `worker-2` — `192.168.56.202`
- Kubernetes `v1.37.x`
- containerd
- Flannel `v0.28.8`

## Uso

Na pasta extraída:

```bash
vagrant up
```

Depois:

```bash
vagrant ssh master-1
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

Os três nodes devem ficar `Ready`.

## O que foi corrigido em relação ao material original

### 1. Box e rede privada

Usa `bento/ubuntu-22.04` e endereços privados únicos `192.168.56.x`.

### 2. DNS do VirtualBox

Mantém o workaround necessário no ambiente testado, usando diretamente:

```text
1.1.1.1
8.8.8.8
```

### 3. cgroup v2 / containerd / kubelet

A configuração do containerd é gerada pela própria versão instalada e então ajustada para:

```toml
SystemdCgroup = true
```

O kubelet também é configurado com `systemd`.

Isso evita o erro:

```text
expected cgroupsPath to be of format "slice:prefix:name" for systemd cgroups
```

### 4. Reinício/ordem correta

O containerd é configurado e reiniciado antes do `kubeadm init/join`. O kubelet também é reiniciado após a configuração/join para evitar que permaneça usando uma decisão antiga de cgroup.

### 5. IP errado dos nodes no VirtualBox

VirtualBox/Vagrant normalmente adiciona uma interface NAT com o mesmo IP (`10.0.2.15`) em todas as VMs.

O kubelet é forçado a usar o IP único da rede privada:

```text
master-1 -> 192.168.56.101
worker-1 -> 192.168.56.201
worker-2 -> 192.168.56.202
```

### 6. Flannel + Vagrant

O Flannel também é forçado a selecionar a interface/endereço `192.168.56.x`, em vez da interface NAT `10.0.2.15`.

Essa correção resolve o comportamento em que os pods `kube-flannel` em todos os nodes apareciam com o mesmo IP e os workers entravam em `Error`.

### 7. Sem chave SSH pessoal obrigatória

O laboratório não depende mais de `~/.ssh/id_rsa` nem `~/.ssh/vagrant`. O acesso às VMs continua sendo feito normalmente com:

```bash
vagrant ssh master-1
vagrant ssh worker-1
vagrant ssh worker-2
```

## Recriar do zero

Se quiser apagar tudo e testar novamente:

```bash
vagrant destroy -f
rm -f join-command.sh
vagrant up
```

## Configurar o kubectl na máquina host

Após o `vagrant up`, copie o `admin.conf` do master e mescle no seu `~/.kube/config`:

```bash
# 1. Buscar o admin.conf do master
vagrant ssh master-1 -c "sudo cat /etc/kubernetes/admin.conf" > /tmp/kubeadm-config.yaml

# 2. Mesclar no kubeconfig local (preserva outros contextos como docker-desktop e EKS)
python3 - <<'EOF'
import yaml, shutil, datetime, os

new_kube = yaml.safe_load(open('/tmp/kubeadm-config.yaml'))
current  = yaml.safe_load(open(os.path.expanduser('~/.kube/config')))

clusters = [c for c in (current.get('clusters') or []) if c.get('name') != 'kubernetes']
contexts = [c for c in (current.get('contexts') or []) if c.get('name') != 'kubernetes-admin@kubernetes']
users    = [u for u in (current.get('users')    or []) if u.get('name') != 'kubernetes-admin']
clusters += [c for c in (new_kube.get('clusters') or []) if c.get('name') == 'kubernetes']
contexts += [c for c in (new_kube.get('contexts') or []) if c.get('name') == 'kubernetes-admin@kubernetes']
users    += [u for u in (new_kube.get('users')    or []) if u.get('name') == 'kubernetes-admin']

merged = {
    'apiVersion': 'v1', 'kind': 'Config', 'preferences': {},
    'clusters': clusters, 'contexts': contexts, 'users': users,
    'current-context': 'kubernetes-admin@kubernetes',
}
cfg = os.path.expanduser('~/.kube/config')
ts  = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
shutil.copy(cfg, f'{cfg}.bak.{ts}')
yaml.dump(merged, open(cfg, 'w'), default_flow_style=False, width=100000)
os.chmod(cfg, 0o600)
print("Atualizado! Backup salvo em:", f'{cfg}.bak.{ts}')
EOF

# 3. Testar
kubectl get nodes
```

> **Nota:** Se as VMs foram apenas reiniciadas (`vagrant halt` / `vagrant up`), os certificados não mudam e o config já existente continua válido. Refaça o passo acima somente após `vagrant destroy` + `vagrant up`.

## Diagnóstico rápido

No master:

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-flannel -o wide
```

Nos nodes:

```bash
grep SystemdCgroup /etc/containerd/config.toml
cat /etc/default/kubelet
systemctl status containerd --no-pager
systemctl status kubelet --no-pager
```
