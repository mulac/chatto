#!/usr/bin/env bash
set -e

echo ""
echo "=== Chatto Cluster Join (Linux/macOS) ==="

# Detect OS + ARCH for kubectl
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  arm64) ARCH="arm64" ;;
  armv7l|armv6l) ARCH="arm" ;;
esac

echo "[+] Platform: $OS / $ARCH"

# ----- Install Tailscale -----
if ! command -v tailscale >/dev/null 2>&1; then
  echo "[+] Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "[+] Ensuring Tailscale is logged in..."
if ! tailscale status >/dev/null 2>&1; then
  sudo tailscale up
fi

# ----- Install kubectl -----
if ! command -v kubectl >/dev/null 2>&1; then
  echo "[+] Installing kubectl..."
  VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/$VERSION/bin/$OS/$ARCH/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "[+] kubectl already installed."
fi

# ----- Install exec-auth plugin -----
if ! command -v kubectl-tailscale-auth >/dev/null 2>&1; then
  echo "[+] Installing kubectl-tailscale-auth..."
  curl -fsSL https://raw.githubusercontent.com/tailscale/k8s-auth/main/install.sh | sudo bash
else
  echo "[+] kubectl-tailscale-auth already installed."
fi

# ----- Write kubeconfig -----
mkdir -p ~/.kube
curl -fsSL https://mulac.github.io/chatto/kubeconfig -o ~/.kube/config

echo ""
echo "✅ Setup complete!"
echo "Run: kubectl get nodes"
echo "(Your browser will prompt you to log in via Tailscale SSO.)"

