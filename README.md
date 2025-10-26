# Chatto

GitOps-managed kubernetes cluster for with app kustomizations.

## Repository Structure

- `apps/` - Core application manifests
  - `kafka/` - Kafka cluster configuration
  - `kafka-operator/` - Kafka Operator via Strimzi
  - `clickhouse/` - ClickHouse deployment via HyperDX
- `cluster/` - The definition of the chatto cluster
  - `environments/` - Namespace managed environments (dev, prod)
  - `platform/` - Core platform components shared across environments
- `sources/` - External resource definitions (external Helm & Git repos)

## Getting Started

```bash
# Linux/macOS
curl -fsSL mulac.github.io/chatto/join.sh | sh

# Windows
iwr mulac.github.io/chatto/join.ps1 | iex
```

This automatically:
1. Installs Tailscale for network access (you must use the chatto tailnet)
2. Installs kubectl if not already
3. Sets up kubeconfig for cluster acces

## Deployment Model

All changes follow GitOps workflow:
1. Commit changes to this repo
2. Flux automatically reconciles cluster state
3. Monitor updates with `kubectl get kustomizations -A`

## Extending

To add applications:
1. Create manifests in `apps/[app-name]/`
2. Link to appropriate environment in `cluster/environments/[env]/`
3. Push changes to trigger Flux reconciliation