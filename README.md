# AWS Route 53 Private Hosted Zone POC

Terraform proof-of-concept that provisions a fully private AWS infrastructure with internal DNS resolution using Route 53 Private Hosted Zones. EC2 instances are deployed in a private subnet with no public internet exposure and are managed securely via AWS Systems Manager (SSM) Session Manager.

## Architecture

```
                        ┌─────────────────────────────────────────────┐
                        │                   VPC (10.0.0.0/16)        │
                        │                                             │
  Internet ◄───► IGW ◄─┤  Public Subnet (10.0.1.0/24)               │
                        │    └── NAT Gateway                         │
                        │                                             │
                        │  Private Subnet (10.0.2.0/24)              │
                        │    ├── EC2 Instance (Amazon Linux 2023)    │
                        │    └── VPC Endpoints (SSM, SSMMessages,    │
                        │                       EC2Messages)         │
                        │                                             │
                        │  Route 53 Private Hosted Zone              │
                        │    └── server.test.internal → EC2 Private IP│
                        └─────────────────────────────────────────────┘
```

## What This Deploys

- **VPC** with public and private subnets, internet gateway, and NAT gateway
- **EC2 instance** in the private subnet running Apache (httpd) web server, no public IP, no SSH key
- **VPC endpoints** for SSM, SSM Messages, and EC2 Messages (enables Session Manager without internet)
- **Route 53 private hosted zone** (`test.internal`) with an A record pointing to the EC2 instance
- **IAM role** with SSM managed instance core policy for secure access
- **Security groups** restricting traffic to HTTPS for VPC endpoints, HTTP from VPC, and egress-only for the EC2 instance

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create VPC, EC2, Route 53, IAM, and VPC endpoint resources

## Usage

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

## Connecting to the Instance

The EC2 instance has no public IP and no SSH key. Connect using SSM Session Manager:

```bash
aws ssm start-session --target <instance_id> --region us-east-1
```

The exact command is provided in the `ssm_start_session` output after `terraform apply`.

## Accessing the Web Server

The EC2 instance runs an Apache web server on port 80. Since it has no public IP, use SSM port forwarding to access it from your laptop:

```bash
# Start port forwarding (copy the ssm_port_forward output from terraform apply)
aws ssm start-session --target <instance_id> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}'
```

Then open http://localhost:8080 in your browser.

## Verifying DNS Resolution

Once connected to the instance via SSM, test private DNS resolution:

```bash
dig server.test.internal
```

The command is also available in the `dns_test_command` output.

## Variables

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidr` | CIDR block for the public subnet | `10.0.1.0/24` |
| `private_subnet_cidr` | CIDR block for the private subnet | `10.0.2.0/24` |
| `private_zone_name` | Domain name for the private hosted zone | `test.internal` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `project_name` | Project name used for resource tagging | `r53-private-zone-test` |
| `web_server_port` | Port the web server listens on | `80` |

## Outputs

| Output | Description |
|---|---|
| `target_instance_id` | EC2 instance ID |
| `target_private_ip` | Private IP address of the EC2 instance |
| `private_zone_id` | Route 53 private hosted zone ID |
| `server_fqdn` | Fully qualified domain name (`server.test.internal`) |
| `ssm_start_session` | AWS CLI command to connect via Session Manager |
| `ssm_port_forward` | AWS CLI command to forward the web server port to localhost:8080 |
| `web_url_local` | URL to access the web server after starting port forwarding |
| `dns_test_command` | Command to verify DNS resolution from the instance |

## Cleanup

```bash
terraform destroy
```
