# AWS Naming Conventions

## General Guidelines

- **Descriptive names:** Names should reflect the resource's purpose. Use `web-prod-server1` instead of `server1`.
- **Lowercase only:** Avoids case sensitivity issues and promotes uniformity.
- **Allowed characters:** Alphanumeric characters and hyphens only. No spaces or special characters.
- **Include environment:** Always specify the environment (`dev`, `test`, `prod`) to differentiate resources across deployment stages.
- **Use tags:** AWS tags provide additional metadata beyond the name (e.g., owner, cost center, project).

---

## Resource-Specific Conventions

- **EC2 Instances**
    - Format: `[project]-[env]-[role]-[identifier]`
    - Example: `myapp-prod-web-01`

- **S3 Buckets**
    - Format: `[project]-[env]-[data-type]-[identifier]`
    - Example: `myapp-prod-logs-backup`

- **IAM Roles**
    - Format: `[role-type]-[project]-[env]`
    - Example: `admin-myapp-prod`

- **RDS Instances**
    - Format: `[project]-[env]-[database-type]-[identifier]`
    - Example: `myapp-prod-mysql-db01`

- **Lambda Functions**
    - Format: `[project]-[env]-[function-purpose]`
    - Example: `myapp-prod-process-upload`

- **CloudFormation Stacks**
    - Format: `[project]-[env]-[stack-purpose]`
    - Example: `myapp-prod-network-stack`

- **VPC**
    - Format: `[project]-[env]-vpc`
    - Example: `myapp-prod-vpc`

- **Subnets**
    - Format: `[project]-[env]-subnet-[region][zone]`
    - Example: `myapp-prod-subnet-us-east-1a`

- **Security Groups**
    - Format: `[project]-[env]-sg-[purpose]`
    - Example: `myapp-prod-sg-web`

- **Elastic Load Balancers**
    - Format: `[project]-[env]-elb-[purpose]`
    - Example: `myapp-prod-elb-web`

- **Target Groups**
    - Format: `[project]-[env]-tg-[purpose]`
    - Example: `myapp-prod-tg-web`

- **Auto Scaling Groups**
    - Format: `[project]-[env]-asg-[purpose]`
    - Example: `myapp-prod-asg-web`

- **Launch Templates**
    - Format: `[project]-[env]-lt-[purpose]`
    - Example: `myapp-prod-lt-web`

- **Internet Gateways**
    - Format: `[project]-[env]-igw`
    - Example: `myapp-prod-igw`

- **NAT Gateways**
    - Format: `[project]-[env]-nat-[region][zone]`
    - Example: `myapp-prod-nat-us-east-1a`

- **Route Tables**
    - Format: `[project]-[env]-rt-[scope]`
    - Example: `myapp-prod-rt-public`, `myapp-prod-rt-private-us-east-1a`

- **DB Subnet Groups**
    - Format: `[project]-[env]-subnet-group-[database-type]`
    - Example: `myapp-prod-subnet-group-mysql`

- **Secrets Manager Secrets**
    - Format: `[project]-[env]-secret-[purpose]`
    - Example: `myapp-prod-secret-rds-credentials`
