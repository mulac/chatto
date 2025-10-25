Write-Host ""
Write-Host "⚠️  WARNING ⚠️" -ForegroundColor Yellow
Write-Host "This script is vibecoded."
Write-Host "Meaning: It *should* work, but has not been tested on a real Windows machine yet." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Do you want to continue? (Y/N)"

if ($confirm -notin @("Y","y")) {
    Write-Host "No worries. Exiting. 🫡"
    exit 1
}

Write-Host ""
Write-Host "=== K3s Cluster Join Script (Windows) ==="

# --- Tailscale Install / Login ---
Write-Host "[+] Checking Tailscale..."
if (-not (Get-Command tailscale.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing Tailscale..."
    Invoke-WebRequest https://tailscale.com/windows.exe -OutFile tailscale-installer.exe
    Start-Process .\tailscale-installer.exe -Wait
}

Write-Host "[+] Ensuring Tailscale is logged in..."
try {
    tailscale status | Out-Null
} catch {
    tailscale up
}

# --- kubectl Install ---
Write-Host "[+] Checking kubectl..."
if (-not (Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing kubectl (curl method)..."
    $version = (Invoke-WebRequest -UseBasicParsing https://dl.k8s.io/release/stable.txt).Content.Trim()
    Invoke-WebRequest -Uri "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe" -OutFile "$env:USERPROFILE\kubectl.exe"
    $env:PATH += ";$env:USERPROFILE"
} else {
    Write-Host "[+] kubectl already installed: $(kubectl version --client --short)"
}

# --- kubeconfig Install ---
Write-Host "[+] Installing kubeconfig..."
$KubeDir = "$env:USERPROFILE\.kube"
New-Item -ItemType Directory -Force -Path $KubeDir | Out-Null
Invoke-WebRequest https://mulac.github.io/chatto/kubeconfig -OutFile "$KubeDir\config"

Write-Host ""
Write-Host "✅ Done!"
Write-Host "Open a new terminal and run: kubectl get nodes"
Write-Host "(Browser login via Tailscale SSO will occur automatically.)"

