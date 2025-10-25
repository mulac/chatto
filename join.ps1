Write-Host "[+] Checking tailscale..."
if (-not (Get-Command tailscale.exe -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest https://tailscale.com/windows.exe -OutFile tailscale-installer.exe
    Start-Process .\tailscale-installer.exe -Wait
}
tailscale up

Write-Host "[+] Checking kubectl..."
if (-not (Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {
    $v = (iwr https://dl.k8s.io/release/stable.txt).Content.Trim()
    iwr "https://dl.k8s.io/release/$v/bin/windows/amd64/kubectl.exe" -OutFile "$env:USERPROFILE\kubectl.exe"
    $env:PATH += ";$env:USERPROFILE"
}

Write-Host "[+] Installing kubeconfig..."
$dir="$env:USERPROFILE\.kube"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
iwr http://100.120.68.88:8000/k3s.yaml -OutFile "$dir\config"

Write-Host "`n✅ Done! Run: kubectl get nodes"

