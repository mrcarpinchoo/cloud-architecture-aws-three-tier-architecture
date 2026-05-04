# AWS Console Guide

Step-by-step guide to build the three-tier architecture through the AWS Console.

### Prerequisites

- AWS Academy Learner Lab session active
- Region set to `us-east-1` (N. Virginia)
- `LabRole` IAM role available

## Step 1 - Create the VPC

1. Go to **VPC** > **Your VPCs** > **Create VPC**.

2. Under **VPC settings**, set:
   - Resources to create: **VPC only**
   - Name tag: `project-dev-vpc`
   - IPv4 CIDR block: **IPv4 CIDR manual input**
   - IPv4 CIDR: `10.0.0.0/16`
   - IPv6 CIDR block: **No IPv6 CIDR block**
   - Tenancy: **Default**

3. Click **Create VPC**.

4. Select the VPC > **Actions** > **Edit VPC settings**.

5. Under **DNS settings**, enable:
   - **Enable DNS resolution**
   - **Enable DNS hostnames**

6. Click **Save**.

## Step 2 - Create Subnets

1. Go to **VPC** > **Subnets** > **Create subnet**.

2. Under **VPC**, set:
   - VPC ID: `project-dev-vpc`

3. Under **Subnet settings**, add all 6 subnets using **Add new subnet** for each:

   | Subnet name                            | Availability Zone | IPv4 subnet CIDR block |
   | -------------------------------------- | ----------------- | ---------------------- |
   | `project-dev-subnet-public-us-east-1a` | us-east-1a        | `10.0.0.0/24`          |
   | `project-dev-subnet-public-us-east-1b` | us-east-1b        | `10.0.1.0/24`          |
   | `project-dev-subnet-app-us-east-1a`    | us-east-1a        | `10.0.2.0/24`          |
   | `project-dev-subnet-app-us-east-1b`    | us-east-1b        | `10.0.3.0/24`          |
   | `project-dev-subnet-db-us-east-1a`     | us-east-1a        | `10.0.4.0/24`          |
   | `project-dev-subnet-db-us-east-1b`     | us-east-1b        | `10.0.5.0/24`          |

4. Click **Create subnets**.

5. Enable **Auto-assign public IPv4** on both public subnets. For each one:
   - Select the subnet > **Actions** > **Edit subnet settings**
   - Under **Auto-assign IP settings**, check **Enable auto-assign public IPv4 address**
   - Click **Save**.

## Step 3 - Create and Attach Internet Gateway

1. Go to **VPC** > **Internet gateways** > **Create internet gateway**.

2. Under **Internet gateway settings**, set:
   - Name tag: `project-dev-igw`

3. Click **Create internet gateway**.

4. Select it > **Actions** > **Attach to VPC**.

5. Under **VPC**, set:
   - Available VPCs: `project-dev-vpc`

6. Click **Attach internet gateway**.

## Step 4 - Create NAT Gateways

Create one NAT Gateway per AZ.

### NAT Gateway 1a

1. Go to **VPC** > **NAT gateways** > **Create NAT gateway**.

2. Under **NAT gateway settings**, set:
   - Name: `project-dev-nat-us-east-1a`
   - Availability mode: **Zonal**
   - Subnet: `project-dev-subnet-public-us-east-1a`
   - Connectivity type: **Public**

3. Click **Allocate Elastic IP**.
4. Click **Create NAT gateway**.

### NAT Gateway 1b

1. Go to **VPC** > **NAT gateways** > **Create NAT gateway**.

2. Under **NAT gateway settings**, set:
   - Name: `project-dev-nat-us-east-1b`
   - Availability mode: **Zonal**
   - Subnet: `project-dev-subnet-public-us-east-1b`
   - Connectivity type: **Public**

3. Click **Allocate Elastic IP**.
4. Click **Create NAT gateway**.

> Wait for both NAT Gateways to show State **Available** before proceeding.

## Step 5 - Create Route Tables

### Public Route Table

1. Go to **VPC** > **Route tables** > **Create route table**.

2. Under **Route table settings**, set:
   - Name: `project-dev-rt-public`
   - VPC: `project-dev-vpc`

3. Click **Create route table**.

4. Select it > **Routes** tab > **Edit routes** > **Add route** and set the following:
   - Destination: `0.0.0.0/0`
   - Target: Internet Gateway > `project-dev-igw`

5. Click **Save changes**.

6. Select **Subnet associations** tab > **Edit subnet associations** and select:
   - `project-dev-subnet-public-us-east-1a`
   - `project-dev-subnet-public-us-east-1b`

7. Click **Save associations**.

### Private Route Table 1a

1. Go to **VPC** > **Route tables** > **Create route table**.

2. Under **Route table settings**, set:
   - Name: `project-dev-rt-private-us-east-1a`
   - VPC: `project-dev-vpc`

3. Click **Create route table**.

4. Select it > **Routes** tab > **Edit routes** > **Add route** and set the following:
   - Destination: `0.0.0.0/0`
   - Target: NAT Gateway > `project-dev-nat-us-east-1a`

5. Click **Save changes**.

6. Select **Subnet associations** tab > **Edit subnet associations** and select:
   - `project-dev-subnet-app-us-east-1a`
   - `project-dev-subnet-db-us-east-1a`

7. Click **Save associations**.

### Private Route Table 1b

1. Go to **VPC** > **Route tables** > **Create route table**.

2. Under **Route table settings**, set:
   - Name: `project-dev-rt-private-us-east-1b`
   - VPC: `project-dev-vpc`

3. Click **Create route table**.

4. Select it > **Routes** tab > **Edit routes** > **Add route** and set the following:
   - Destination: `0.0.0.0/0`
   - Target: NAT Gateway > `project-dev-nat-us-east-1b`

5. Click **Save changes**.

6. Select **Subnet associations** tab > **Edit subnet associations** and select:
   - `project-dev-subnet-app-us-east-1b`
   - `project-dev-subnet-db-us-east-1b`

7. Click **Save associations**.

## Step 6 - Create Security Groups

All security groups use VPC: `project-dev-vpc`.

### 6.1 - Create All Security Groups (Empty)

Go to **VPC** > **Security groups** > **Create security group** for each:

1. For `project-dev-sg-bastion`, set under **Basic details**:
   - Security group name: `project-dev-sg-bastion`
   - Description: Bastion host security group
   - VPC: `project-dev-vpc`

2. For `project-dev-sg-db`, set under **Basic details**:
   - Security group name: `project-dev-sg-db`
   - Description: DB tier security group
   - VPC: `project-dev-vpc`

3. For `project-dev-sg-app`, set under **Basic details**:
   - Security group name: `project-dev-sg-app`
   - Description: App tier security group
   - VPC: `project-dev-vpc`

4. For `project-dev-sg-alb`, set under **Basic details**:
   - Security group name: `project-dev-sg-alb`
   - Description: ALB security group
   - VPC: `project-dev-vpc`

> For each one, remove the default outbound rule under **Outbound rules** before saving, except for `project-dev-sg-bastion` (leave its outbound as default).

### 6.2 - Add Rules

For `project-dev-sg-bastion`:

1. Go to `project-dev-sg-bastion` > **Inbound rules** > **Edit inbound rules**. Add:
   - Type: SSH
   - Protocol: TCP
   - Port range: 22
   - Source: `0.0.0.0/0`
   - Description: SSH from admin device
2. Click **Save rules**.

For `project-dev-sg-db`:

1. Go to `project-dev-sg-db` > **Inbound rules** > **Edit inbound rules**. Add:
   - Type: MYSQL/Aurora
   - Protocol: TCP
   - Port range: 3306
   - Source: `project-dev-sg-app`
   - Description: MySQL from app tier only
2. Add a second rule:
   - Type: MYSQL/Aurora
   - Protocol: TCP
   - Port range: 3306
   - Source: `project-dev-sg-bastion`
   - Description: MySQL from bastion
3. Click **Save rules**.

For `project-dev-sg-app`:

1. Go to `project-dev-sg-app` > **Inbound rules** > **Edit inbound rules**. Add:
   - Type: HTTP
   - Protocol: TCP
   - Port range: 80
   - Source: `project-dev-sg-alb`
   - Description: HTTP from ALB only
2. Add a second rule:
   - Type: SSH
   - Protocol: TCP
   - Port range: 22
   - Source: `project-dev-sg-bastion`
   - Description: SSH from bastion only
3. Click **Save rules**.
4. Go to `project-dev-sg-app` > **Outbound rules** > **Edit outbound rules**. Add:
   - Type: MYSQL/Aurora
   - Protocol: TCP
   - Port range: 3306
   - Destination: `project-dev-sg-db`
   - Description: MySQL to DB tier
5. Add a second rule:
   - Type: HTTPS
   - Protocol: TCP
   - Port range: 443
   - Destination: `0.0.0.0/0`
   - Description: AWS APIs, S3, dnf updates
6. Click **Save rules**.

For `project-dev-sg-alb`:

1. Go to `project-dev-sg-alb` > **Inbound rules** > **Edit inbound rules**. Add:
   - Type: HTTP
   - Protocol: TCP
   - Port range: 80
   - Source: `0.0.0.0/0`
   - Description: HTTP from internet
2. Click **Save rules**.
3. Go to `project-dev-sg-alb` > **Outbound rules** > **Edit outbound rules**. Add:
   - Type: HTTP
   - Protocol: TCP
   - Port range: 80
   - Destination: `project-dev-sg-app`
   - Description: Forward to app tier
4. Click **Save rules**.

## Step 7 - Create RDS MySQL Instance

### 7.1 - Create DB Subnet Group

1. Go to **RDS** > **Subnet groups** > **Create DB subnet group**.

2. Under **Subnet group details**, set:
   - Name: `project-dev-subnet-group-mysql`
   - Description: DB subnet group for MySQL
   - VPC: `project-dev-vpc`

3. Under **Add subnets**, set:
   - Availability Zones: `us-east-1a` and `us-east-1b`
   - Subnets:
     - `project-dev-subnet-db-us-east-1a`
     - `project-dev-subnet-db-us-east-1b`

4. Click **Create**.

### 7.2 - Create RDS Instance

1. Go to **RDS** > **Databases** > **Create database** > **Full configuration**.

2. Under **Engine options**, set:
   - Engine type: **MySQL**

3. Under **Choose a database creation method**, select:
   - **Full configuration**

4. Under **Templates**, select:
   - **Dev/Test**

5. Under **Availability and durability**, set:
   - Deployment options: **Single-AZ DB instance deployment**

6. Under **Settings**, set:
   - Engine version: **MySQL 8.4.8**
   - DB instance identifier: `project-dev-mysql-db01`

7. Under **Credentials Settings**, set:
   - Master username: `admin`
   - Credentials management: **Managed in AWS Secrets Manager**

8. Under **Instance configuration**, set:
   - DB instance class: **Burstable classes**
   - Instance type: `db.t3.micro`

9. Under **Storage**, set:
   - Storage type: **gp2**
   - Allocated storage: `20` GB

10. Under **Additional storage configuration**, set:
    - Storage autoscaling: **Disabled**

11. Under **Connectivity**, set:
    - Virtual private cloud (VPC): `project-dev-vpc`
    - DB subnet group: `project-dev-subnet-group-mysql`
    - Public access: **No**
    - VPC security group (firewall): **Choose existing**
    - Existing VPC security groups: `project-dev-sg-db` (remove default)
    - Availability Zone: `us-east-1a`

12. Under **Monitoring**, set:
    - Additional monitoring settings > Enhanced Monitoring: **Disabled**

13. Under **Additional configuration**, set:
    - Database options > Initial database name: `countries`
    - Backup > Enable automated backups: **Disabled**

14. Click **Create database**.

> **Note**: Wait for the instance status to show **Available**. This can take 5-10 minutes.

## Step 8 - Create S3 Bucket and Upload Files

1. Go to **S3** > **Create bucket**.

2. Under **General configuration**, set:
   - Bucket type: **General purpose**
   - Bucket namespace: **Account Regional namespace**
   - Bucket name prefix: `project-dev-artifacts`

3. Leave all other settings as default and click **Create bucket**.

> **Note**: After creation, AWS will show the full bucket name in the format `project-dev-artifacts-<account-regional-suffix>`. Copy it — you'll need it in the next steps.

4. Copy the user data template and replace the bucket name placeholder:

   ```bash
   cp terraform/modules/compute/templates/user-data.sh.tpl scripts/user-data.sh
   ```

   Open `scripts/user-data.sh` and replace `${s3_bucket_name}` with your actual full bucket name.

5. Upload the app and scripts from your local machine:
   ```bash
   aws s3 sync app/ s3://project-dev-artifacts-<account-regional-suffix>/app/
   aws s3 cp db/countries.sql s3://project-dev-artifacts-<account-regional-suffix>/countries.sql
   aws s3 cp scripts/db-import.sh s3://project-dev-artifacts-<account-regional-suffix>/db-import.sh
   ```

## Step 9 - Create Key Pair

1. Go to **EC2** > **Key Pairs** > **Create key pair**.

2. Under **Key pair**, set:
   - Name: `project-dev-keypair`
   - Key pair type: **RSA**
   - Private key file format:
     - `.pem` — for use with OpenSSH (Linux/Mac)
     - `.ppk` — for use with PuTTY (Windows)

3. Click **Create key pair**. The file downloads automatically — keep it safe.

## Step 10 - Launch Bastion Host

1. Go to **EC2** > **Instances** > **Launch instances**.

2. Under **Name and tags**, set:
   - Name: `project-dev-bastion`

3. Under **Application and OS Images**, set:
   - Quick Start: **Amazon Linux**
   - Amazon Machine Image (AMI): **Amazon Linux 2023 kernel-6.1 AMI**

4. Under **Instance type**, set:
   - Instance type: `t3.micro`

5. Under **Key pair (login)**, set:
   - Key pair name: `project-dev-keypair`

6. Under **Network settings**, click **Edit** and set:
   - VPC: `project-dev-vpc`
   - Subnet: `project-dev-subnet-public-us-east-1a`
   - Auto-assign public IP: **Enable**
   - Firewall (security groups): **Select existing security group**
   - Common security groups: `project-dev-sg-bastion`

7. Under **Advanced details**, set:
   - IAM instance profile: `LabRole`

8. Click **Launch instance**.

## Step 11 - Import Data into RDS

> Before running the import, confirm the RDS instance status shows **Available** in **RDS** > **Databases**.

1. Set the correct permissions on the key file:
   ```bash
   chmod 400 project-dev-keypair.pem
   ```
2. Copy the key to the bastion:
   ```bash
   scp -i project-dev-keypair.pem project-dev-keypair.pem ec2-user@<bastion-public-ip>:~
   ```
3. SSH into the bastion:
   ```bash
   ssh -i project-dev-keypair.pem ec2-user@<bastion-public-ip>
   ```
4. Set the correct permissions on the key file on the bastion:
   ```bash
   chmod 400 project-dev-keypair.pem
   ```
5. Pull the import script from S3 and run it:
   ```bash
   aws s3 cp s3://project-dev-artifacts-<account-regional-suffix>/db-import.sh .
   chmod +x db-import.sh
   ./db-import.sh
   ```

The script installs the MySQL client, downloads the dump from S3, retrieves credentials from Secrets Manager, imports the data, and verifies the row count.

## Step 12 - Create Launch Template

1. Go to **EC2** > **Launch Templates** > **Create launch template**.

2. Under **Launch template name and description**, set:
   - Launch template name: `project-dev-lt-app`
   - Template version description: `Launch template for app tier`
   - Auto Scaling guidance: **Enable** (check "Provide guidance to help me set up a template that I can use with EC2 Auto Scaling")

3. Under **Application and OS Images**, set:
   - Quick Start: **Amazon Linux**
   - Amazon Machine Image (AMI): **Amazon Linux 2023 kernel-6.1 AMI**

4. Under **Instance type**, set:
   - Instance type: `t3.micro`

5. Under **Key pair (login)**, set:
   - Key pair name: `project-dev-keypair`

6. Under **Network settings**, set:
   - Subnet: **Don't include in launch template**
   - Firewall (security groups): **Select existing security group**
   - Security groups: `project-dev-sg-app`

7. Under **Advanced details**, set:
   - IAM instance profile: `LabRole`
   - User data: paste the contents of `scripts/user-data.sh`

8. Click **Create launch template**.

## Step 13 - Create Target Group

1. Go to **EC2** > **Target Groups** > **Create target group**.

2. Under **Settings**, set:
   - Target type: **Instances**
   - Target group name: `project-dev-tg-app`
   - Protocol: **HTTP**
   - Port: `80`
   - IP address type: **IPv4**
   - VPC: `project-dev-vpc`
   - Protocol version: **HTTP1**

3. Under **Health checks**, set:
   - Health check protocol: **HTTP**
   - Health check path: `/index.php`

4. Under **Advanced health check settings**, set:
   - Healthy threshold: `2`
   - Unhealthy threshold: `3`
   - Timeout: `5`
   - Interval: `30`
   - Success codes: `200`

5. Click **Next** — do not register targets manually.
6. Click **Create target group**.

## Step 14 - Create Application Load Balancer

1. Go to **EC2** > **Load Balancers** > **Create Load Balancer** > select **Application Load Balancer**.

2. Under **Basic configuration**, set:
   - Load balancer name: `project-dev-elb-web`
   - Scheme: **Internet-facing**
   - Load balancer IP address type: **IPv4**

3. Under **Network mapping**, set:
   - VPC: `project-dev-vpc`
   - Availability Zones and subnets:
     - `us-east-1a` → `project-dev-subnet-public-us-east-1a`
     - `us-east-1b` → `project-dev-subnet-public-us-east-1b`

4. Under **Security groups**, set:
   - Remove the default security group
   - Select: `project-dev-sg-alb`

5. Under **Listeners and routing**, set:
   - Protocol: **HTTP** | Port: `80`
   - Default action > Routing action: **Forward to target groups**
   - Default action > Forward to target group > Target group: `project-dev-tg-app`

6. Click **Create load balancer**.

## Step 15 - Create Auto Scaling Group

Go to **EC2** > **Auto Scaling Groups** > **Create Auto Scaling group**.

### Step 1 - Choose launch template or configuration

1. Under **Name**, set:
   - Auto Scaling group name: `project-dev-asg-app`
2. Under **Launch template**, set:
   - Launch template: `project-dev-lt-app`
3. Click **Next**.

### Step 2 - Choose instance launch options

1. Under **Network**, set:
   - VPC: `project-dev-vpc`
   - Availability Zones and subnets: `project-dev-subnet-app-us-east-1a` and `project-dev-subnet-app-us-east-1b`
   - Availability Zone distribution: **Balanced best effort**
2. Click **Next**.

### Step 3 - Integrate with other services

1. Under **Load balancing**, set:
   - Select Load balancing options: **Attach to an existing load balancer**
   - Attach to an existing load balancer
     - Select the load balancers to attach: **Choose from your load balancer target groups**
     - Existing load balancer target groups: `project-dev-tg-app | HTTP`
2. Under **Health checks**, enable:
   - **Turn on Elastic Load Balancing health checks**
   - Health check grace period: `300` seconds
3. Click **Next**.

### Step 4 - Configure group size and scaling

1. Under **Group size**, set:
   - Desired capacity: `2`
2. Under **Scaling**, set:
   - Scaling limits
     - Min desired capacity: `2`
     - Max desired capacity: `4`
   - Automatic scaling
     - Choose whether to use a target tracking policy: **Target tracking scaling policy**
     - Scaling policy name: `project-dev-scaling-policy`
     - Metric type: **Average CPU utilization**
     - Target value: `60`
3. Click **Next**.

### Steps 5, 6, 7 - Notifications, Tags, Review

Skip steps 5 and 6 (leave defaults). On step 7, review the configuration and click **Create Auto Scaling group**.

> **Note**: The ASG will launch 2 instances. Wait for them to pass health checks in the target group before testing.

## Step 16 - Test the Application

1. Go to **EC2** > **Load Balancers** > select `project-dev-elb-web`.
2. Copy the **DNS name** and open it in a browser.
3. You should see the Example Social Research Organization homepage.
4. Click **Query** and run a query to verify the database connection works.

## Cleanup (When Done)

To preserve your lab budget, tear down resources in this order:

1. Delete the Auto Scaling Group
2. Terminate the Bastion instance
3. Delete the Load Balancer
4. Delete the Target Group
5. Delete the Launch Template
6. Delete the RDS instance (skip final snapshot)
7. Delete the DB Subnet Group
8. Delete the NAT Gateways (wait for them to fully delete)
9. Release the Elastic IPs
10. Delete the Security Groups
11. Delete the Subnets
12. Delete the Route Tables (non-main ones)
13. Detach and delete the Internet Gateway
14. Delete the VPC
15. Empty and delete the S3 bucket
