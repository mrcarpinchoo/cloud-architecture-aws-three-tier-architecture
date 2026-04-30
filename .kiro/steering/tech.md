# Tech Stack

## Application

- **Runtime:** PHP (on Amazon Linux 2023)
- **Database:** MySQL (Amazon RDS, `db.t3.micro`, database name: `countries`)
- **Web server:** Hosted on EC2 `t2.micro` instances

## AWS Services

| Service                   | Purpose                                              |
| ------------------------- | ---------------------------------------------------- |
| Amazon VPC                | Network isolation, subnets, routing                  |
| Amazon EC2 + ASG          | Application tier with Auto Scaling                   |
| Application Load Balancer | Internet-facing entry point, multi-AZ                |
| Amazon RDS (MySQL)        | Managed database, single-AZ (Learner Lab constraint) |
| NAT Gateway               | Outbound internet for private subnets                |
| AWS Secrets Manager       | RDS credentials storage and retrieval                |
| IAM                       | EC2 instance role for Secrets Manager access         |

## Infrastructure as Code

- **Tool:** Terraform (Phase 2 — after manual build is validated)
- Terraform state files (`*.tfstate`, `*.tfstate.backup`) and the `.terraform/` directory are gitignored

## Common Commands

### Terraform

```bash
terraform init        # Initialize working directory
terraform plan        # Preview changes
terraform apply       # Apply infrastructure changes
terraform destroy     # Tear down infrastructure
```

## Credentials & Secrets

- Database credentials are stored in **AWS Secrets Manager** — never hardcoded in application code or committed to the repo
- `.env` files are gitignored; use `.env.example` as a template
