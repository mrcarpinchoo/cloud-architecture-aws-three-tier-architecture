# Cloud Architecture Final Project - Three-Tier Architecture on AWS

A highly available PHP web application deployed on AWS, serving global development statistics for social science researchers. The infrastructure follows AWS best practices: private subnets for application and database tiers, a public-facing Application Load Balancer, Auto Scaling, and AWS Secrets Manager for credential management.

## Table of Contents

- [Scenario](#scenario)
- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Infrastructure Components](#infrastructure-components)
- [Design Decisions](#design-decisions)
- [Implementation Phases](#implementation-phases)
- [Cost Estimate](#cost-estimate)

## Scenario

The Example Social Research Organization is a fictional non-profit that provides a website where social science researchers can query global development statistics (e.g., life expectancy by country over the last 10 years).

The site was originally hosted on a commercial provider and later migrated to a single EC2 instance in a public subnet — running both the PHP application and MySQL on the same machine. After a ransomware attempt and growing traffic complaints, the architecture was redesigned to be secure, scalable, and highly available on AWS.

## Architecture Overview

The architecture diagram is available in `docs/architecture-diagrams/`.

```
Internet
  └── ALB (public subnets: us-east-1a, us-east-1b)
        └── EC2 / ASG (private app subnets: us-east-1a, us-east-1b)
              └── RDS MySQL (private DB subnet: us-east-1a)
```

> The architecture diagram shows RDS Multi-AZ. However, since this project runs on an AWS Academy Learner Lab, **RDS Multi-AZ is not supported**. A single RDS instance is deployed in `us-east-1a`.

## Repository Structure

```
├── app/          # PHP web application source
├── db/           # SQL dump for the countries database
├── docs/         # Architecture diagrams, infrastructure spec, and build guide
├── scripts/      # EC2 user data and database import scripts
└── README.md
```

## Infrastructure Components

| Component           | Service                | Details                                                       |
| ------------------- | ---------------------- | ------------------------------------------------------------- |
| VPC                 | Amazon VPC             | `project-dev-vpc`, us-east-1, `10.0.0.0/16`                   |
| Public Subnets      | VPC Subnet             | `project-dev-subnet-public-us-east-1a/1b`                     |
| Private App Subnets | VPC Subnet             | `project-dev-subnet-app-us-east-1a/1b`                        |
| Private DB Subnets  | VPC Subnet             | `project-dev-subnet-db-us-east-1a/1b`                         |
| Internet Gateway    | IGW                    | `project-dev-igw`, attached to VPC                            |
| NAT Gateways        | NAT GW                 | `project-dev-nat-us-east-1a/1b`, one per AZ (Zonal)           |
| Bastion Host        | EC2 (t3.micro)         | `project-dev-bastion`, in public subnet, admin SSH access     |
| Load Balancer       | ALB                    | `project-dev-elb-web`, internet-facing, multi-AZ              |
| Target Group        | ALB Target Group       | `project-dev-tg-app`, HTTP port 80, health check `/index.php` |
| Application Servers | EC2 (t3.micro)         | Amazon Linux 2023, PHP app, in private app subnets            |
| Auto Scaling        | ASG + Launch Template  | `project-dev-asg-app`, target tracking 60% CPU                |
| Database            | Amazon RDS MySQL 8.4.8 | `project-dev-mysql-db01`, `db.t3.micro`, DB: `countries`      |
| Secrets             | AWS Secrets Manager    | RDS credentials, auto-managed by RDS integration              |
| IAM                 | IAM Role               | `LabRole`, pre-configured, attached to EC2 instances          |
| Artifacts           | S3                     | App files, DB dump, and scripts                               |

## Design Decisions

- **Private subnets for app and database tiers** — EC2 instances and RDS are not directly accessible from the internet, reducing the attack surface.
- **Bastion host** — single controlled entry point for admin SSH access to private instances and database import.
- **NAT Gateways (one per AZ)** — allow instances in private subnets to reach the internet for updates and AWS API calls without exposing them to inbound traffic.
- **ALB in public subnets** — serves as the single entry point, distributing traffic across application instances in multiple AZs.
- **Auto Scaling** — automatically adjusts the number of EC2 instances based on CPU utilization, improving availability and cost efficiency.
- **AWS Secrets Manager** — keeps database credentials out of application code, supporting secret rotation.
- **Separate DB subnets** — isolates the database tier from the application tier at the network level for defense in depth.

## Implementation Phases

### Phase 1 - Manual build via AWS Console

The full infrastructure was built and validated through the AWS Management Console. See the [Manual Build Guide](docs/manual-build-guide.md) for the complete step-by-step guide.

### Phase 2 - Infrastructure as Code with Terraform

Once the manual build is validated, the entire infrastructure will be reproduced in Terraform for repeatable, version-controlled deployments.

## Cost Estimate (us-east-1, on-demand)

| Resource                                                 | Monthly (USD)  |
| -------------------------------------------------------- | -------------- |
| Amazon RDS for MySQL (db.t3.micro, Single-AZ, 20 GB gp2) | ~$29.42        |
| Application Load Balancer                                | ~$16.93        |
| Amazon EC2 (2× t3.micro, 50% utilization)                | ~$7.59         |
| NAT Gateways (2×)                                        | ~$33.30        |
| AWS Secrets Manager (1 secret, 100 API calls/day)        | ~$0.42         |
| **Total (monthly)**                                      | **~$87.66**    |
| **Total (annual)**                                       | **~$1,051.94** |

> Prices are estimates and subject to change. Use the [AWS Pricing Calculator](https://calculator.aws/pricing/2/homescreen) for up-to-date figures.
