# Product

This is a cloud infrastructure project for the **Example Social Research Organization**, a fictional non-profit. The product is a highly available PHP web application hosted on AWS that lets social science researchers query global development statistics (e.g., life expectancy by country over time).

## Background

The site was originally on a commercial host, then moved to a single EC2 instance running both the PHP app and MySQL. After a ransomware attempt and performance issues, the architecture is being redesigned for security, scalability, and high availability.

## Goals

- Secure three-tier architecture (public ALB → private app tier → private DB tier)
- High availability across two Availability Zones (us-east-1a, us-east-1b)
- Auto Scaling for the application tier
- Credential management via AWS Secrets Manager
- Reproducible infrastructure via Terraform (Phase 2)

## Constraints

- Runs on AWS Academy Learner Lab — RDS Multi-AZ is **not supported**; a single RDS instance is used instead
- Region: us-east-1
