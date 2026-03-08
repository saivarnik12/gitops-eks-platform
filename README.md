# 🚀 Industry-Scale GitOps Platform — Multi-Tenant Kubernetes on AWS EKS

A production-grade, multi-tenant Kubernetes platform on **AWS EKS** built with **GitOps principles**. Every infrastructure and application change flows through Git — no manual `kubectl` in production.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub                               │
│   ┌──────────────┐      ┌──────────────────────────────┐   │
│   │  App Repos   │─────▶│  GitOps Config Repo (this)   │   │
│   └──────────────┘      └──────────────┬─────────────-─┘   │
└────────────────────────────────────────│────────────────────┘
                                         │ ArgoCD watches
┌────────────────────────────────────────▼────────────────────┐
│                     AWS EKS Cluster                         │
│                                                             │
│  ┌──────────────┐  ┌────────────┐  ┌─────────────────────┐ │
│  │   ArgoCD     │  │ Prometheus │  │      Datadog         │ │
│  │  (GitOps)    │  │  Grafana   │  │    APM / Tracing     │ │
│  └──────────────┘  └────────────┘  └─────────────────────┘ │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │  Service │  │  Service │  │  Kafka   │  │   Redis   │  │
│  │    A     │  │    B     │  │ (Strimzi)│  │  Cluster  │  │
│  └──────────┘  └──────────┘  └──────────┘  └───────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              PostgreSQL (Persistent Volume)           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
          │                    │
   ┌──────▼──────┐     ┌───────▼──────┐
   │  Terraform  │     │  GitHub      │
   │  (IaC)      │     │  Actions CI  │
   └─────────────┘     └──────────────┘
```

---

## 📁 Project Structure

```
gitops-eks-platform/
├── terraform/
│   ├── modules/
│   │   ├── eks/          # EKS cluster, node groups, IRSA
│   │   ├── vpc/          # VPC, subnets, NAT gateway
│   │   └── iam/          # IAM roles and policies
│   └── envs/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── helm-charts/
│   ├── base-service/     # Reusable Helm chart for microservices
│   └── monitoring/       # Prometheus + Grafana stack
├── argocd/
│   ├── apps/             # ArgoCD Application manifests
│   └── projects/         # ArgoCD Project definitions
├── observability/
│   ├── dashboards/       # Grafana dashboard JSON
│   └── alerts/           # Alertmanager rules
├── .github/
│   └── workflows/        # GitHub Actions CI pipelines
└── docs/
    └── runbook.md        # Operational runbook
```

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Cloud | AWS (EKS, EC2, VPC, IAM, S3, ECR) |
| IaC | Terraform |
| Orchestration | Kubernetes, Helm |
| GitOps | ArgoCD (App-of-Apps) |
| CI | GitHub Actions |
| Observability | Prometheus, Grafana, Alertmanager |
| APM | Datadog |
| Messaging | Kafka (Strimzi Operator) |
| Caching | Redis |
| Database | PostgreSQL |
| Security | RBAC, Network Policies, IRSA, Secrets encryption |

---

## 🚀 Getting Started

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- kubectl
- Helm >= 3.x
- ArgoCD CLI

### 1. Provision Infrastructure
```bash
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl
```bash
aws eks update-kubeconfig --region ap-south-1 --name eks-dev-cluster
kubectl get nodes
```

### 3. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/projects/
kubectl apply -f argocd/apps/app-of-apps.yaml
```

### 4. Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Get initial password
argocd admin initial-password -n argocd
```

### 5. Deploy Monitoring Stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring helm-charts/monitoring -n monitoring --create-namespace
```

---

## 🔒 Security Features

- **IRSA** (IAM Roles for Service Accounts) — zero long-lived credentials
- **RBAC** — namespace-scoped roles per tenant
- **Network Policies** — deny-all default, explicit allow rules
- **Secrets** — encrypted at rest using AWS KMS
- **Least-privilege IAM** — per-service IAM roles

---

## 📊 SLO Targets

| Service | Availability SLO | Latency P99 |
|---|---|---|
| API Gateway | 99.9% | < 200ms |
| Order Service | 99.5% | < 500ms |
| Inventory Service | 99.5% | < 300ms |

---

## 📖 Runbook

See [docs/runbook.md](docs/runbook.md) for incident response procedures.
