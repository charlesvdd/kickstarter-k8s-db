# 🛠️ Database Maintenance Strategy

This repository documents the maintenance strategy for a multi-database stack including:
- MongoDB
- SQL (PostgreSQL / MySQL)
- Prisma ORM

---

## 📅 Update Schedule

| Component  | Patch Frequency | Major Upgrade | Notes |
|------------|------------------|----------------|-------|
| MongoDB    | Monthly (security) | Every 6–12 months | Use `mongod --version` to monitor version |
| PostgreSQL / MySQL | Monthly | Every 12–18 months | Test queries and indexes after upgrades |
| Prisma ORM | Monthly (`npm update`) | As needed | Use `prisma migrate` carefully |

---

## 🔐 Security Guidelines

### Access Control
- Enforce **RBAC** for database users.
- Use **.env** files (never versioned) to store credentials.
- Rotate access keys every 90 days.
- Restrict access via **firewall rules** or **VPN**.

### Network & Encryption
- Enable **TLS/SSL** for all connections.
- Disable public network access for production databases.
- Enable MongoDB `auth = true` and restrict `bindIp`.

### Prisma ORM
- Never expose `.env` or schema with credentials.
- Validate relations and permissions with `@relation`.

---

## 💾 Backup & Recovery Plan

### MongoDB
| Type       | Frequency   | Tools                    |
|------------|-------------|--------------------------|
| `mongodump` | Daily      | Scripted via cron job    |
| Snapshot   | Hourly (Atlas) | Use MongoDB Atlas or cloud tools |
| Archive    | Weekly      | Export JSON to cold storage |

### PostgreSQL / MySQL
| Type       | Frequency   | Tools                         |
|------------|-------------|-------------------------------|
| SQL Dump   | Daily       | `pg_dump` / `mysqldump`       |
| Binary Copy | Weekly     | `rsync` + volume snapshot     |
| PITR (WAL) | 5 min (PG)  | PostgreSQL Write-Ahead Logging |

### Restore Tests
- Perform a full restoration on a staging VM once per month.

---

## ⚙️ Prisma Maintenance

- Always run `prisma generate` after editing the `schema.prisma`.
- Backup database before using `prisma migrate deploy`.
- Review any pending migration SQL files.

---

## 📈 Monitoring & Alerts

Recommended Stack:
- **Prometheus + Grafana** for performance monitoring
- **Fail2Ban / AuditD** for suspicious activity
- **Log parsing tools** for slow queries and errors
- **Plausible / DataDog / Sentry** for API and ORM observability

---

## 🧪 Continuous Testing

- Use Docker-based staging environments for testing migrations.
- Include Prisma CLI in CI/CD pipelines to validate schema changes.
- Automate backup before each `git push main`.

---

## 📜 License

MIT © 2025 [Charles Van den Driessche – www.neomnia.net](https://www.neomnia.net)

