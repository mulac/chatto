Write-Host ""
Write-Host "⚠️  THIS SCRIPT IS VIBECODED ⚠️" -ForegroundColor Yellow
Write-Host "It *should* work, but has not been tested on a real Windows machine yet."
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -notin @("Y","y")) { exit 1 }

Write-Host "=== Chatto Cluster Join (Windows) ==="

# Tailscale
if (-not (Get-Command tailscale.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing Tailscale..."
    iwr https://tailscale.com/windows.exe -OutFile tailscale-installer.exe
    Start-Process .\tailscale-installer.exe -Wait
}
try { tailscale status | Out-Null } catch { tailscale up }

# kubectl
if (-not (Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing kubectl (curl method)..."
    $version = (iwr https://dl.k8s.io/release/stable.txt).Content.Trim()
    iwr "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe" -OutFile "$env:USERPROFILE\kubectl.exe"
    $env:PATH += ";$env:USERPROFILE"
}

# kubectl-tailscale-auth
if (-not (Get-Command kubectl-tailscale-auth.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing kubectl-tailscale-auth..."
    iwr https://raw.githubusercontent.com/tailscale/k8s-auth/main/install.ps1 | iex
}

# kubeconfig
$KubeDir="$env:USERPROFILE\.kube"
New-Item -ItemType Directory -Force -Path $KubeDir | Out-Null
iwr https://mulac.github.io/chatto/kubeconfig -OutFile "$KubeDir\config"

Write-Host ""
Write-Host "✅ Done!"
Write-Host "Open a NEW terminal and run: kubectl get nodes"

