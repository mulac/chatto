#!/usr/bin/env bash
set -e

echo "[+] Ensuring tailscale..."
if ! command -v tailscale >/dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi
sudo tailscale up || true

echo "[+] Ensuring kubectl..."
if ! command -v kubectl >/dev/null; then
  VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
  curl -LO "https://dl.k8s.io/release/$VERSION/bin/$OS/$ARCH/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

echo "[+] Fetching shared kubeconfig..."
mkdir -p ~/.kube
curl -fsSL http://100.120.68.88:8000/k3s.yaml -o ~/.kube/config

echo "✅ Done. Try: kubectl get nodes"

