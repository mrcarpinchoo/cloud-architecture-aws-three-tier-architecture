# Project Structure

```
/
├── app/                   # PHP web application source
│   ├── index.php
│   ├── query.php / query2.php / query3.php
│   ├── get-parameters.php # Fetches RDS endpoint + Secrets Manager credentials at runtime
│   ├── mobile.php / population.php / lifeexpectancy.php / gdp.php / mortality.php
│   ├── menu.php / style.css
│   └── Logo.png / Shirley.jpeg
├── db/
│   └── countries.sql      # SQL dump for the countries database
├── docs/
│   ├── architecture-diagrams/
│   │   ├── Final project - Architecture diagram.drawio   # Editable diagram source
│   │   └── Final project - Architecture diagram.png     # Exported image (gitignored)
│   ├── aws-console-guide.md   # Step-by-step manual build guide (AWS Console)
│   ├── infrastructure.md      # Full infrastructure specification
│   └── naming-conventions.md  # AWS resource naming conventions
├── scripts/
│   ├── db-import.sh       # Database import script — run from bastion to populate RDS from S3
│   └── user-data.sh       # Generated from template — gitignored, contains actual bucket name
├── terraform/
│   ├── environments/
│   │   └── dev/           # Dev environment — run terraform commands from here
│   └── modules/
│       ├── network/       # VPC, subnets, IGW, NAT Gateways, route tables
│       ├── security/      # Security groups
│       ├── data/          # RDS instance and DB subnet group
│       └── compute/       # Bastion, ALB, target group, launch template, ASG
├── .kiro/
│   └── steering/          # AI assistant guidance files
├── .gitignore
├── LICENSE
└── README.md
```

## Conventions

- Architecture diagrams are kept in `docs/architecture-diagrams/`. The `.drawio` source is committed; exported `.png` files are gitignored.
- Terraform code lives in `terraform/`. Run all Terraform commands from `terraform/environments/dev/` or use the `-chdir` flag from the repo root.
- PHP application source lives in `app/`. It is deployed to EC2 instances via S3 + user data script — not served directly from the repo.
- `app/get-parameters.php` is the credential bootstrap — it uses the AWS SDK (`vendor/autoload.php`) to fetch the RDS endpoint via `describeDBInstances` and credentials from Secrets Manager.
- Database SQL dump lives in `db/`. Use `db/countries.sql` to populate the `countries` database on RDS via `scripts/db-import.sh`.

## Three-Tier Network Layout

```
Internet
  └── ALB (public subnets: project-public-us-east-1a/1b)
        └── EC2 / ASG (private app subnets: project-app-us-east-1a/1b)
              └── RDS MySQL (private DB subnets: project-db-us-east-1a/1b)
```

- Public subnets hold the ALB and NAT Gateways only
- App and DB tiers have no direct internet exposure
- NAT Gateways (one per AZ) provide outbound-only internet access for private subnets
