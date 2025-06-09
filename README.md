# 🛠️ Kubernetes-Based DB Maintenance Strategy

> Containerized and orchestrated maintenance strategy for:
- MongoDB
- PostgreSQL / MySQL
- Prisma ORM

Fully managed using **Kubernetes**, with support for backup, security, and lifecycle management.

---

## 📦 Deployment Overview

All database instances are deployed as **StatefulSets** (Mongo/Postgres) or **Helm Charts**.

Each stack includes:
- 🛡️ Sealed Secrets / SecretStore
- 📦 Persistent Volumes (PVC)
- 🔄 Scheduled CronJobs
- 🔐 TLS / RBAC / NetworkPolicy
- 🧪 CI/CD (optional)

---

## 📅 Update Strategy

| Component     | Patch Rhythm    | Major Version Update | Tool/Method              |
|---------------|------------------|------------------------|--------------------------|
| MongoDB       | Monthly          | Yearly (test before)   | Helm + image tag update |
| PostgreSQL    | Monthly          | Every 12–18 months     | `bitnami/postgresql`    |
| Prisma ORM    | Every 2–4 weeks  | With project changes   | `npm update`, `migrate` |

Use Kubernetes `ImagePullPolicy: Always` for rolling patch updates.

---

## 🔐 Security by Design

### 🔒 Secrets
- Use **Sealed Secrets** (Bitnami) or **External Secrets Operator**.
- Never mount `.env` directly—use Kubernetes Secrets with volume mounts or env vars.

### 🔐 Network & Access
- Enforce **TLS** between services.
- Define `NetworkPolicy` to isolate DB pods.
- Use **RBAC** and service accounts for access restriction.

### Prisma ORM
- Enforce strict input validation.
- Place Prisma behind an internal service (`ClusterIP`) or API gateway.
- Use `npx prisma validate` in CI pipelines.

---

## 💾 Backup & Recovery via Kubernetes CronJobs

### Example: MongoDB CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-backup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: mongo:7
              command: ["sh", "-c", "mongodump --uri=$MONGO_URI --archive=/backup/mongo-$(date +%F).gz --gzip"]
              envFrom:
                - secretRef:
                    name: mongodb-secrets
              volumeMounts:
                - mountPath: /backup
                  name: backup-volume
          restartPolicy: OnFailure
          volumes:
            - name: backup-volume
              persistentVolumeClaim:
                claimName: mongo-backup-pvc
