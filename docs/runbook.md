# 📖 Platform Operations Runbook

## Table of Contents
- [Incident Response Process](#incident-response-process)
- [Pod CrashLoop](#pod-crashloop)
- [Error Budget Burn](#error-budget-burn)
- [Node Not Ready](#node-not-ready)
- [Kafka Consumer Lag](#kafka-consumer-lag)
- [Database Connection Issues](#database-connection-issues)

---

## Incident Response Process

1. **Acknowledge** the alert in PagerDuty within 5 minutes
2. **Assess severity** (P1 = production down, P2 = degraded, P3 = warning)
3. **Communicate** in #incidents Slack channel
4. **Mitigate** using steps below
5. **Resolve** and write RCA within 24 hours for P1/P2

---

## Pod CrashLoop

**Alert:** `PodCrashLooping`

### Diagnosis
```bash
# Get pod status
kubectl get pods -n <namespace>

# Check recent events
kubectl describe pod <pod-name> -n <namespace>

# Check logs (last 100 lines)
kubectl logs <pod-name> -n <namespace> --tail=100

# Check previous container logs
kubectl logs <pod-name> -n <namespace> --previous
```

### Common Causes & Fixes
| Cause | Fix |
|---|---|
| OOM Killed | Increase memory limits in Helm values |
| Config error | Check ConfigMap / Secret mounts |
| Health check failing | Verify `/health` endpoint is reachable |
| ImagePullBackOff | Check ECR credentials and image tag |

### Escalation
If not resolved in 15 minutes → escalate to on-call senior engineer.

---

## Error Budget Burn

**Alert:** `ErrorBudgetBurnRateCritical`

### Diagnosis
```bash
# Check error rate in Grafana SLO dashboard
# URL: http://grafana.internal/d/slo-dashboard

# Check recent 5xx errors
kubectl logs -l app=<service-name> -n <namespace> | grep "5[0-9][0-9]"

# Check upstream dependencies
kubectl get pods -n <namespace>
```

### Rollback Procedure
```bash
# Rollback to previous ArgoCD sync
argocd app rollback <app-name> --revision <previous-revision>

# Or rollback Helm release
helm rollback <release-name> -n <namespace>

# Verify rollback
kubectl rollout status deployment/<deployment-name> -n <namespace>
```

---

## Node Not Ready

**Alert:** `NodeNotReady`

### Diagnosis
```bash
# Check node status
kubectl get nodes

# Describe the affected node
kubectl describe node <node-name>

# Check system pods on node
kubectl get pods --all-namespaces --field-selector spec.nodeName=<node-name>
```

### Remediation
```bash
# Cordon node (prevent new scheduling)
kubectl cordon <node-name>

# Drain node safely
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# If node is in AWS EC2, terminate and let ASG replace it
aws ec2 terminate-instances --instance-ids <instance-id>
```

---

## Kafka Consumer Lag

**Alert:** `KafkaConsumerLagCritical`

### Diagnosis
```bash
# Check consumer group lag
kubectl exec -n kafka kafka-0 -- bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --describe --group <consumer-group>

# Check topic partition count
kubectl exec -n kafka kafka-0 -- bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --topic <topic-name>
```

### Remediation
- Scale up consumer pods: `kubectl scale deployment <consumer> --replicas=<n> -n <namespace>`
- If persistent: increase partition count and rebalance

---

## Database Connection Issues

### Diagnosis
```bash
# Check PostgreSQL pod
kubectl get pods -n postgres

# Test connectivity from application pod
kubectl exec -it <app-pod> -n <namespace> -- \
  psql -h postgres-service.postgres.svc.cluster.local -U appuser -d appdb -c "SELECT 1"

# Check connection pool metrics in Grafana
```

---

## Contacts

| Role | Contact |
|---|---|
| Platform On-Call | PagerDuty: Platform Team |
| Escalation | #devops-escalation (Slack) |
| Postmortem Template | [Google Doc Template](#) |
