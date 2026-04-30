# Cloud Architecture Final Project - Three-tier Architecture on AWS

A highly available PHP web application deployed on AWS, serving global development statistics for social science researchers. The infrastructure is built following AWS best practices: private subnets for application and database tiers, a public-facing Application Load Balancer, Auto Scaling, and AWS Secrets Manager for credential management.

## Table of Contents

- [Scenario](#scenario)
- [Architecture Overview](#architecture-overview)
- [Infrastructure Components](#infrastructure-components)
- [Deploying the Application](#deploying-the-application)
- [Implementation Phases](#implementation-phases)
- [Cost Estimate](#cost-estimate)

## Scenario

The Example Social Research Organization is a fictional non-profit that provides a website where social science researchers can query global development statistics (e.g., life expectancy by country over the last 10 years).

The site was originally hosted on a commercial provider and later migrated to a single EC2 instance in a public subnet — running both the PHP application and MySQL on the same machine. After a ransomware attempt and growing traffic complaints, the architecture is being redesigned to be secure, scalable, and highly available on AWS.

## Architecture Overview

The architecture diagram is available in `docs/architecture-diagrams/`.

> **Note:** The diagram shows RDS Multi-AZ with a primary in `us-east-1a` and a standby in `us-east-1b`. However, since this project runs on an AWS Academy Learner Lab, **RDS Multi-AZ is not supported**. A single RDS instance is deployed in the `us-east-1a` DB subnet.

## Infrastructure Components

| Component           | Service               | Details                                                          |
| ------------------- | --------------------- | ---------------------------------------------------------------- |
| VPC                 | Amazon VPC            | `project-vpc`, single region (us-east-1)                         |
| Public Subnets      | VPC Subnet            | `project-public-us-east-1a`, `project-public-us-east-1b`         |
| Private App Subnets | VPC Subnet            | `project-app-us-east-1a`, `project-app-us-east-1b`               |
| Private DB Subnets  | VPC Subnet            | `project-db-us-east-1a`, `project-db-us-east-1b`                 |
| Internet Gateway    | IGW                   | Attached to VPC                                                  |
| NAT Gateways        | NAT GW                | One per public subnet (one per AZ)                               |
| Load Balancer       | ALB                   | Multi-AZ, internet-facing, in public subnets                     |
| Application Servers | EC2 (t2.micro)        | Amazon Linux 2023, PHP app, in private app subnets               |
| Auto Scaling        | ASG + Launch Template | Target tracking scaling policy                                   |
| Database            | Amazon RDS MySQL      | Single instance in `project-db-us-east-1a`, DB name: `countries` |
| Secrets             | AWS Secrets Manager   | Stores RDS connection credentials                                |
| IAM                 | IAM Role              | Pre-configured role attached to EC2 instances                    |

## Design Decisions

- **Private subnets for app and database tiers** - EC2 instances and RDS are not directly accessible from the internet, reducing the attack surface.
- **NAT Gateway** - Allows instances in private subnets to reach the internet for updates and patches without exposing them to inbound traffic.
- **ALB in public subnets** - Serves as the single entry point, distributing traffic across application instances in multiple AZs.
- **Auto Scaling** - Automatically adjusts the number of EC2 instances based on demand, improving availability and cost efficiency.
- **AWS Secrets Manager** - Keeps database credentials out of application code and instance metadata, supporting secret rotation.
- **Separate DB subnets** - Isolates the database tier from the application tier at the network level for defense in depth.

## Deploying the Application

The PHP application lives in `app/` and is deployed to EC2 instances via S3. The user data script at `scripts/ec2-user-data.sh` runs automatically on each instance boot and pulls the app down from S3.

### 1. Upload the app to S3

Create an S3 bucket and sync the app files to it:

```bash
aws s3 sync app/ s3://project-app-artifacts/app/
```

### 2. Grant the EC2 IAM role access to S3

The EC2 instances use an IAM role to authenticate with AWS — no credentials needed in the script. Add the following permissions to that role, scoped to the bucket:

```
s3:GetObject
s3:ListBucket
```

Applied to:

- `arn:aws:s3:::project-app-artifacts`
- `arn:aws:s3:::project-app-artifacts/*`

Once these are in place, attach `scripts/ec2-user-data.sh` to the Launch Template and new instances will install Apache, PHP, the AWS SDK, and the app automatically on first boot.

## Implementation Phases

### Phase 1 - Manual build via AWS Console

Build and validate the full infrastructure through the AWS Management Console. A step-by-step guide will be produced and refined based on what works in the AWS Academy Learner Lab environment.

### Phase 2 - Infrastructure as Code with Terraform

Once the manual build is validated, the entire infrastructure will be reproduced in Terraform for repeatable, version-controlled deployments.

## Cost Estimate (us-east-1, on-demand)

| Resource                                                 | Monthly (USD)  |
| -------------------------------------------------------- | -------------- |
| Amazon RDS for MySQL (db.t3.micro, Single-AZ, 20 GB gp2) | ~$29.42        |
| Application Load Balancer                                | ~$16.93        |
| Amazon EC2 (2× t3.micro, 50% utilization)                | ~$7.59         |
| NAT Gateway (1)                                          | ~$33.30        |
| AWS Secrets Manager (1 secret, 100 API calls/day)        | ~$0.42         |
| **Total (monthly)**                                      | **~$87.66**    |
| **Total (annual)**                                       | **~$1,051.94** |

> Prices are estimates and subject to change. Use the [AWS Pricing Calculator](https://calculator.aws/pricing/2/homescreen) for up-to-date figures.
