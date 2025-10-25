#!/usr/bin/env bash
set -e

echo ""
echo "=== K3s Cluster Join Script (Linux/macOS) ==="

# --- Detect OS Name (linux / darwin) ---
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

# --- Detect Architecture & Normalize for Kubernetes ---
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="arm" ;;
  armv6l) ARCH="arm" ;;
  arm64) ARCH="arm64" ;;
esac

echo "[+] Detected platform: $OS / $ARCH"

# --- Tailscale Install / Login ---
echo "[+] Checking for Tailscale..."
if ! command -v tailscale >/dev/null 2>&1; then
  echo "[+] Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "[+] Ensuring Tailscale is logged in..."
if ! tailscale status >/dev/null 2>&1; then
  sudo tailscale up
fi

# --- kubectl Install ---
echo "[+] Checking kubectl..."
if ! command -v kubectl >/dev/null 2>&1; then
  echo "[+] Installing kubectl (curl method)..."
  VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/$VERSION/bin/$OS/$ARCH/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "[+] kubectl already installed: $(kubectl version --client --short)"
fi

# --- kubeconfig Install ---
echo "[+] Installing kubeconfig..."
mkdir -p ~/.kube
curl -fsSL https://mulac.github.io/chatto/kubeconfig -o ~/.kube/config

echo ""
echo "✅ Done!"
echo "Test access:   kubectl get nodes"
echo "(Browser login via Tailscale OIDC will occur automatically if needed.)"

