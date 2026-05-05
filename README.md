# Cloud Architecture Final Project - Three-Tier Architecture on AWS

A highly available PHP web application deployed on AWS, serving global development statistics for social science researchers. The infrastructure follows AWS best practices: private subnets for application and database tiers, a public-facing Application Load Balancer, Auto Scaling, and AWS Secrets Manager for credential management.

## Table of Contents

- [Scenario](#scenario)
- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Infrastructure Components](#infrastructure-components)
- [Design Decisions](#design-decisions)
- [Deployment](#deployment)

## Scenario

The Example Social Research Organization is a fictional non-profit that provides a website where social science researchers can query global development statistics (e.g., life expectancy by country over the last 10 years).

The site was originally hosted on a commercial provider and later migrated to a single EC2 instance in a public subnet — running both the PHP application and MySQL on the same machine. After a ransomware attempt and growing traffic complaints, the architecture was redesigned to be secure, scalable, and highly available on AWS.

## Architecture Overview

![Architecture Diagram](docs/architecture-diagrams/Final%20project%20-%20Architecture%20diagram.png)

```
Internet
  └── ALB (public subnets: us-east-1a, us-east-1b)
        └── EC2 / ASG (private app subnets: us-east-1a, us-east-1b)
              └── RDS MySQL (private DB subnet: us-east-1a)
```

> **Note**: The architecture diagram shows RDS Multi-AZ. However, since this project runs on an AWS Academy Learner Lab, **RDS Multi-AZ is not supported**. A single RDS instance is deployed in `us-east-1a`.

## Repository Structure

```
├── app/          # PHP web application source
├── db/           # SQL dump for the countries database
├── docs/         # Architecture diagrams, infrastructure spec, and build guides
├── scripts/      # Database import script and generated user data
├── terraform/    # Terraform IaC — environments and reusable modules
└── README.md
```

## Infrastructure Components

| Component           | Service                | Details                                                         |
| ------------------- | ---------------------- | --------------------------------------------------------------- |
| VPC                 | Amazon VPC             | `project-dev-vpc`, us-east-1, `10.0.0.0/16`                     |
| Public Subnets      | VPC Subnet             | `project-dev-subnet-public-us-east-1a/1b`                       |
| Private App Subnets | VPC Subnet             | `project-dev-subnet-app-us-east-1a/1b`                          |
| Private DB Subnets  | VPC Subnet             | `project-dev-subnet-db-us-east-1a/1b`                           |
| Internet Gateway    | IGW                    | `project-dev-igw`, attached to VPC                              |
| NAT Gateways        | NAT GW                 | `project-dev-nat-us-east-1a/1b`, one per AZ (Zonal)             |
| Bastion Host        | EC2 (t3.micro)         | `project-dev-bastion`, in public subnet, admin SSH access       |
| Load Balancer       | ALB                    | `project-dev-elb-web`, internet-facing, multi-AZ                |
| Target Group        | ALB Target Group       | `project-dev-tg-app`, HTTP port 80, health check `/index.php`   |
| Application Servers | EC2 (t3.micro)         | Amazon Linux 2023, PHP app, in private app subnets              |
| Auto Scaling        | ASG + Launch Template  | `project-dev-asg-app`, target tracking 60% CPU                  |
| Database            | Amazon RDS MySQL 8.4.8 | `project-dev-mysql-db01`, `db.t3.micro`, DB: `countries`        |
| Secrets             | AWS Secrets Manager    | RDS credentials, auto-managed by RDS integration                |
| IAM                 | IAM Role               | `LabInstanceProfile`, pre-configured, attached to EC2 instances |
| Artifacts           | S3                     | App files, DB dump, and scripts                                 |

## Design Decisions

- **Private subnets for app and database tiers** — EC2 instances and RDS are not directly accessible from the internet, reducing the attack surface.
- **Bastion host** — single controlled entry point for admin SSH access to private instances and database import.
- **NAT Gateways (one per AZ)** — allow instances in private subnets to reach the internet for updates and AWS API calls without exposing them to inbound traffic.
- **ALB in public subnets** — serves as the single entry point, distributing traffic across application instances in multiple AZs.
- **Auto Scaling** — automatically adjusts the number of EC2 instances based on CPU utilization, improving availability and cost efficiency.
- **AWS Secrets Manager** — keeps database credentials out of application code, supporting secret rotation.
- **Separate DB subnets** — isolates the database tier from the application tier at the network level for defense in depth.

## Deployment

This deployment uses Terraform to provision the full infrastructure. For a manual alternative, see the [AWS Console Guide](docs/aws-console-guide.md) for a step-by-step walkthrough through the AWS Console.

### Prerequisites

1. Create a key pair. This is used to SSH into the bastion host and app instances:

   ```sh
   aws ec2 create-key-pair \
      --key-name project-dev-keypair \
      --query KeyMaterial \
      --output text > project-dev-keypair.pem
   ```

2. Set the correct permissions on the key file. SSH will refuse to use it otherwise:

   ```sh
   chmod 400 project-dev-keypair.pem
   ```

3. Create the S3 bucket. It will store the app source, the SQL dump, and the DB import script (all pulled by EC2 instances at boot time):

   ```sh
   ACCOUNT_ID=$(
      aws sts get-caller-identity \
         --query Account \
         --output text
   )

   BUCKET_NAME="project-dev-artifacts-${ACCOUNT_ID}-us-east-1-an"

   aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region us-east-1 \
      --bucket-namespace account-regional

   echo "Bucket name: $BUCKET_NAME"
   ```

   To retrieve the bucket name in a new terminal session:

   ```sh
   BUCKET_NAME=$(
      aws s3api list-buckets \
         --query "Buckets[?starts_with(Name, 'project-dev-artifacts')].Name" \
         --output text
   )

   echo "Bucket name: $BUCKET_NAME"
   ```

4. Upload artifacts to S3:

   ```sh
   aws s3 sync app/ s3://$BUCKET_NAME/app/
   aws s3 cp db/countries.sql s3://$BUCKET_NAME/countries.sql
   aws s3 cp scripts/db-import.sh s3://$BUCKET_NAME/db-import.sh
   ```

### Deploy

To deploy the infrastructure:

1. Initialize Terraform:

   ```sh
   terraform -chdir=terraform/environments/dev init
   ```

2. Preview the changes:

   ```sh
   terraform -chdir=terraform/environments/dev plan \
      -var-file=dev.tfvars \
      -var="s3_bucket_name=$BUCKET_NAME"
   ```

3. Deploy:

   ```sh
   terraform -chdir=terraform/environments/dev apply \
      -var-file=dev.tfvars \
      -var="s3_bucket_name=$BUCKET_NAME"
   ```

To view the outputs at any time:

```sh
terraform -chdir=terraform/environments/dev output
```

### Import Database

Once `terraform apply` completes, to import the database:

1. Look up the bastion's public IP:

   ```sh
   BASTION_IP=$(
      aws ec2 describe-instances \
         --filters \
            "Name=tag:Name,Values=project-dev-bastion" \
            "Name=instance-state-name,Values=running" \
         --query "Reservations[0].Instances[0].PublicIpAddress" \
         --output text
   )
   ```

2. SSH into the bastion with agent forwarding:

   ```sh
   ssh -A -i project-dev-keypair.pem ec2-user@$BASTION_IP
   ```

   The `-A` flag forwards the local SSH agent to the bastion, so app instances in private subnets can be reached from there using the local key without copying the key file to the bastion.

3. Set the bucket name variable:

   ```sh
   BUCKET_NAME=$(
      aws s3api list-buckets \
         --query "Buckets[?starts_with(Name, 'project-dev-artifacts')].Name" \
         --output text
   )
   ```

4. Pull the import script from S3:

   ```sh
   aws s3 cp s3://$BUCKET_NAME/db-import.sh .
   ```

5. Run it:

   ```sh
   chmod +x db-import.sh
   ./db-import.sh
   ```

### Access the App

Open the ALB DNS name shown in Terraform outputs in your browser.
