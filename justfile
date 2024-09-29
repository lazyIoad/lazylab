# Install or update vendored dependencies
ansible-install:
  cd ansible && ansible-galaxy install -r requirements.yml

# Bootstrap all nodes
ansible-bootstrap:
  cd ansible && ansible-playbook -i inventory.yml playbooks/bootstrap.yml -Kk

# Install k3s on all nodes
ansible-k3s-install:
  cd ansible && ansible-playbook -i inventory.yml playbooks/k3s-install.yml

# Uninstall k3s from all nodes
ansible-k3s-uninstall:
  cd ansible && ansible-playbook -i inventory.yml playbooks/k3s-uninstall.yml

# Update OS for all nodes
ansible-update:
  cd ansible && ansible-playbook -i inventory.yml playbooks/update.yml

# Bootstrap kubernetes cluster
k8s-bootstrap: ansible-k3s-install flux-bootstrap sops-bootstrap

# Do complete bootstrap
bootstrap: ansible-bootstrap k8s-bootstrap

# Bootstrap sops secrets in the cluster
sops-bootstrap:
  cat $SOPS_AGE_KEY_FILE | kubectl create secret generic sops-keys \
    --namespace flux-system \
    --from-file age.agekey=/dev/stdin

# Bootstrap Flux onto the cluster
flux-bootstrap:
  flux bootstrap github \
    --token-auth \
    --owner=lazyIoad \
    --repository=lazylab \
    --branch=master \
    --path=./kubernetes/clusters/home \
    --personal
