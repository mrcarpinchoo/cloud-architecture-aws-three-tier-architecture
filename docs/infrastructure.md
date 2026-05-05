# Infrastructure Specification

## Network Topology

```
Internet
  └── Internet Gateway
        └── ALB (project-dev-subnet-public-us-east-1a, project-dev-subnet-public-us-east-1b)
              └── Target Group → EC2 instances (Auto Scaling Group)
                    ├── project-dev-subnet-app-us-east-1a (EC2)
                    └── project-dev-subnet-app-us-east-1b (EC2)
                          └── RDS MySQL (project-dev-subnet-db-us-east-1a)

NAT Gateway (project-dev-subnet-public-us-east-1a) → project-dev-subnet-app-us-east-1a outbound
NAT Gateway (project-dev-subnet-public-us-east-1b) → project-dev-subnet-app-us-east-1b outbound

Bastion (project-dev-subnet-public-us-east-1a) → admin SSH to app tier / DB import to RDS
```

---

## VPC

| Setting        | Value             |
| -------------- | ----------------- |
| Name           | `project-dev-vpc` |
| CIDR           | `10.0.0.0/16`     |
| Region         | `us-east-1`       |
| DNS hostnames  | Enabled           |
| DNS resolution | Enabled           |

---

## Subnets

| Name                                   | Type    | AZ         | CIDR          |
| -------------------------------------- | ------- | ---------- | ------------- |
| `project-dev-subnet-public-us-east-1a` | Public  | us-east-1a | `10.0.0.0/24` |
| `project-dev-subnet-public-us-east-1b` | Public  | us-east-1b | `10.0.1.0/24` |
| `project-dev-subnet-app-us-east-1a`    | Private | us-east-1a | `10.0.2.0/24` |
| `project-dev-subnet-app-us-east-1b`    | Private | us-east-1b | `10.0.3.0/24` |
| `project-dev-subnet-db-us-east-1a`     | Private | us-east-1a | `10.0.4.0/24` |
| `project-dev-subnet-db-us-east-1b`     | Private | us-east-1b | `10.0.5.0/24` |

Public subnets have **Auto-assign public IPv4** enabled.

---

## Internet Gateway

| Setting     | Value             |
| ----------- | ----------------- |
| Name        | `project-dev-igw` |
| Attached to | `project-dev-vpc` |

---

## NAT Gateways

| Name                         | Subnet                                 | Type                         | Availability Mode |
| ---------------------------- | -------------------------------------- | ---------------------------- | ----------------- |
| `project-dev-nat-us-east-1a` | `project-dev-subnet-public-us-east-1a` | Public (Elastic IP required) | Zonal             |
| `project-dev-nat-us-east-1b` | `project-dev-subnet-public-us-east-1b` | Public (Elastic IP required) | Zonal             |

---

## Route Tables

### Public Route Table (`project-dev-rt-public`)

Associated with: `project-dev-subnet-public-us-east-1a`, `project-dev-subnet-public-us-east-1b`

| Destination   | Target            |
| ------------- | ----------------- |
| `10.0.0.0/16` | local             |
| `0.0.0.0/0`   | `project-dev-igw` |

### Private Route Table 1a (`project-dev-rt-private-us-east-1a`)

Associated with: `project-dev-subnet-app-us-east-1a`, `project-dev-subnet-db-us-east-1a`

| Destination   | Target                       |
| ------------- | ---------------------------- |
| `10.0.0.0/16` | local                        |
| `0.0.0.0/0`   | `project-dev-nat-us-east-1a` |

### Private Route Table 1b (`project-dev-rt-private-us-east-1b`)

Associated with: `project-dev-subnet-app-us-east-1b`, `project-dev-subnet-db-us-east-1b`

| Destination   | Target                       |
| ------------- | ---------------------------- |
| `10.0.0.0/16` | local                        |
| `0.0.0.0/0`   | `project-dev-nat-us-east-1b` |

---

## Security Groups

### ALB Security Group (`project-dev-sg-alb`)

**Inbound**

| Port | Protocol | Source      | Description        |
| ---- | -------- | ----------- | ------------------ |
| 80   | TCP      | `0.0.0.0/0` | HTTP from internet |

**Outbound**

| Port | Protocol | Destination          | Description         |
| ---- | -------- | -------------------- | ------------------- |
| 80   | TCP      | `project-dev-sg-app` | Forward to app tier |

---

### Bastion Security Group (`project-dev-sg-bastion`)

**Inbound**

| Port | Protocol | Source      | Description           |
| ---- | -------- | ----------- | --------------------- |
| 22   | TCP      | `0.0.0.0/0` | SSH from admin laptop |

> **Note**: In production, restrict the SSH source to your specific IP (`x.x.x.x/32`) instead of `0.0.0.0/0`.

**Outbound**

| Port | Protocol | Destination | Description  |
| ---- | -------- | ----------- | ------------ |
| All  | All      | `0.0.0.0/0` | All outbound |

### App Tier Security Group (`project-dev-sg-app`)

**Inbound**

| Port | Protocol | Source                   | Description           |
| ---- | -------- | ------------------------ | --------------------- |
| 80   | TCP      | `project-dev-sg-alb`     | HTTP from ALB only    |
| 22   | TCP      | `project-dev-sg-bastion` | SSH from bastion only |

**Outbound**

| Port | Protocol | Destination         | Description                                |
| ---- | -------- | ------------------- | ------------------------------------------ |
| 3306 | TCP      | `project-dev-sg-db` | MySQL to DB tier                           |
| 443  | TCP      | `0.0.0.0/0`         | HTTPS outbound (AWS APIs, S3, yum updates) |

---

### DB Tier Security Group (`project-dev-sg-db`)

**Inbound**

| Port | Protocol | Source                   | Description                    |
| ---- | -------- | ------------------------ | ------------------------------ |
| 3306 | TCP      | `project-dev-sg-app`     | MySQL from app tier only       |
| 3306 | TCP      | `project-dev-sg-bastion` | MySQL from bastion (DB import) |

**Outbound**

| Port | Protocol | Destination | Description          |
| ---- | -------- | ----------- | -------------------- |
| All  | All      | None        | No outbound required |

---

## Application Load Balancer

| Setting        | Value                                                                          |
| -------------- | ------------------------------------------------------------------------------ |
| Name           | `project-dev-elb-web`                                                          |
| Scheme         | Internet-facing                                                                |
| IP type        | IPv4                                                                           |
| Subnets        | `project-dev-subnet-public-us-east-1a`, `project-dev-subnet-public-us-east-1b` |
| Security group | `project-dev-sg-alb`                                                           |

### Listeners

| Port | Protocol | Action                          |
| ---- | -------- | ------------------------------- |
| 80   | HTTP     | Forward to `project-dev-tg-app` |

### Target Group (`project-dev-tg-app`)

| Setting               | Value        |
| --------------------- | ------------ |
| Target type           | Instances    |
| Protocol              | HTTP         |
| Port                  | 80           |
| Health check path     | `/index.php` |
| Health check interval | 30s          |
| Healthy threshold     | 2            |
| Unhealthy threshold   | 3            |

---

## Bastion Host

| Setting              | Value                                  |
| -------------------- | -------------------------------------- |
| Name                 | `project-dev-bastion`                  |
| AMI                  | Amazon Linux 2023 (latest, us-east-1)  |
| Instance type        | `t3.micro`                             |
| Subnet               | `project-dev-subnet-public-us-east-1a` |
| Public IP            | Enabled                                |
| IAM instance profile | `LabInstanceProfile`                   |
| Security group       | `project-dev-sg-bastion`               |
| Key pair             | `project-dev-keypair`                  |

The bastion serves two purposes:

- **Admin SSH access** to app tier instances (laptop → bastion → EC2)
- **Database import** (laptop → bastion → RDS via MySQL client)

## EC2 / Auto Scaling

### Launch Template (`project-dev-lt-app`)

| Setting              | Value                                                                                          |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| AMI                  | Amazon Linux 2023 (latest, us-east-1)                                                          |
| Instance type        | `t3.micro`                                                                                     |
| IAM instance profile | `LabInstanceProfile`                                                                           |
| Security group       | `project-dev-sg-app`                                                                           |
| User data            | `scripts/user-data.sh` (generated from `terraform/modules/compute/templates/user-data.sh.tpl`) |

### Auto Scaling Group (`project-dev-asg-app`)

| Setting          | Value                                                                    |
| ---------------- | ------------------------------------------------------------------------ |
| Launch template  | `project-dev-lt-app`                                                     |
| Subnets          | `project-dev-subnet-app-us-east-1a`, `project-dev-subnet-app-us-east-1b` |
| Minimum capacity | 2                                                                        |
| Desired capacity | 2                                                                        |
| Maximum capacity | 4                                                                        |
| Target group     | `project-dev-tg-app`                                                     |

### Scaling Policy

| Setting            | Value                   |
| ------------------ | ----------------------- |
| Type               | Target tracking         |
| Metric             | Average CPU utilization |
| Target value       | 60%                     |
| Scale-in cooldown  | 300s                    |
| Scale-out cooldown | 300s                    |

---

## RDS

| Setting        | Value                             |
| -------------- | --------------------------------- |
| Name           | `project-dev-mysql-db01`          |
| Engine         | MySQL 8.x                         |
| Instance class | `db.t3.micro`                     |
| Storage        | 20 GB gp2                         |
| DB name        | `countries`                       |
| Subnet group   | `project-dev-subnet-group-mysql`  |
| Security group | `project-dev-sg-db`               |
| Multi-AZ       | Disabled (Learner Lab constraint) |
| Public access  | No                                |
| Credentials    | Managed by AWS Secrets Manager    |

### DB Subnet Group (`project-dev-subnet-group-mysql`)

Includes: `project-dev-subnet-db-us-east-1a`, `project-dev-subnet-db-us-east-1b`

---

## AWS Secrets Manager

The RDS master credentials are stored as a Secrets Manager secret. The secret name follows the pattern `rds!<identifier>` (auto-generated by RDS when you enable Secrets Manager integration during instance creation).

`get-parameters.php` retrieves the secret at runtime using `listSecrets` filtered by the `rds!` prefix, then calls `getSecretValue` to obtain `username` and `password`.

Required IAM permissions on `LabInstanceProfile`:

- `secretsmanager:ListSecrets`
- `secretsmanager:GetSecretValue`
- `rds:DescribeDBInstances`
- `s3:GetObject`, `s3:ListBucket` on `project-dev-artifacts-<account-regional-suffix>`
