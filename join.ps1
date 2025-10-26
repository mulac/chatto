# --- Tailscale ---
Write-Host "[+] Checking tailscale..."
# We check the default, hardcoded path, as the PATH variable won't update in this session
$tailscalePath = "C:\Program Files\Tailscale\tailscale.exe"

if (-not (Test-Path $tailscalePath)) {
    Write-Host "Tailscale not found. Installing..."
    Invoke-WebRequest https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe -OutFile tailscale-installer.exe
    # Run the installer and wait for it to finish
    Start-Process .\tailscale-installer.exe -Wait
    # Clean up the installer
    Remove-Item .\tailscale-installer.exe
    
    # Verify the file exists after installation
    if (-not (Test-Path $tailscalePath)) {
        Write-Host "Error: Tailscale installation failed or not found at $tailscalePath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Tailscale already installed."
}

Write-Host "[+] Running 'tailscale up'..."
# Run the command using its full path
& $tailscalePath up
if ($LastExitCode -ne 0) {
    # This error check is for the command *failing*, not being *found*
    Write-Host "Error: 'tailscale up' command failed. It may require interactive login." -ForegroundColor Red
    exit 1
}


# --- kubectl ---
Write-Host "[+] Checking kubectl..."

# Define a standard, user-specific program location
$kubectlDir = "$env:LOCALAPPDATA\Programs\kubectl"
$kubectlPath = "$kubectlDir\kubectl.exe"

# Ensure the directory exists
New-Item -ItemType Directory -Force -Path $kubectlDir | Out-Null

if (-not (Test-Path $kubectlPath)) {
    Write-Host "kubectl not found. Installing to $kubectlDir..."
    $v = (Invoke-WebRequest https://dl.k8s.io/release/stable.txt).Content.Trim()
    Write-Host "Downloading kubectl version $v..."
    Invoke-WebRequest "https://dl.k8s.io/release/$v/bin/windows/amd64/kubectl.exe" -OutFile $kubectlPath
} else {
    Write-Host "kubectl already found at $kubectlPath."
}

# --- Update PATH ---
# 1. Add to the *current session's* PATH so the script can continue
if ($env:PATH -notlike "*$kubectlDir*") {
    Write-Host "Adding '$kubectlDir' to session PATH..."
    $env:PATH += ";$kubectlDir"
}

# 2. Add to the *User's persistent* PATH for future terminals
$currentUserPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
if ($currentUserPath -notlike "*$kubectlDir*") {
    Write-Host "Adding '$kubectlDir' to User's permanent PATH..."
    $newPath = $currentUserPath + ";$kubectlDir"
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "Please restart your terminal after this script finishes for the change to take full effect."
}

# --- Verify ---
kubectl --help | Out-Null
if ($LastExitCode -ne 0) {
    Write-Host "Error: 'kubectl --version' command failed." -ForegroundColor Red
    exit 1
}


Write-Host "[+] Installing kubeconfig..."
$dir="$env:USERPROFILE\.kube"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
# This doesn't work!!!
iwr http://100.120.68.88:8000/k3s.yaml -OutFile "$dir\config"

Write-Host "`n✅ Done! Run: kubectl get nodes"

