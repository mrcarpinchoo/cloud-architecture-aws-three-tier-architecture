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
│   └── architecture-diagrams/
│       ├── Final project - Architecture diagram.drawio   # Editable diagram source
│       └── Final project - Architecture diagram.png     # Exported image (gitignored)
├── scripts/
│   ├── ec2-user-data.sh   # EC2 bootstrap script — installs Apache, PHP, AWS SDK, deploys app from S3
│   └── db-import.sh       # Database import script — run from bastion to populate RDS from S3
├── .kiro/
│   └── steering/          # AI assistant guidance files
├── .gitignore
├── LICENSE
└── README.md
```

## Conventions

- Architecture diagrams are kept in `docs/architecture-diagrams/`. The `.drawio` source is committed; exported `.png` files are gitignored.
- Terraform code (Phase 2) should live at the repo root or in a dedicated `terraform/` directory when added.
- PHP application source lives in `app/`. It is deployed to EC2 instances (e.g., via S3 + user data script) — not served directly from the repo.
- `app/get-parameters.php` is the credential bootstrap — it uses the AWS SDK (`aws-autoloader.php`) to fetch the RDS endpoint via `describeDBInstances` and credentials from Secrets Manager. The SDK must be present on the EC2 instance.
- Database SQL dump lives in `db/`. Use `db/countries.sql` to populate the `countries` database on RDS.

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
