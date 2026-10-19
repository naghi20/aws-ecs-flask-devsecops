# AWS ECS Flask DevSecOps CI/CD Platform

A portfolio project demonstrating a secure, automated CI/CD platform for a containerized Flask API on AWS.

## Architecture

```text
GitHub push
  -> GitHub Actions tests + Trivy/Checkov scans
  -> Docker image pushed to Amazon ECR
  -> ECS Fargate rolling deployment
  -> ALB routes traffic to healthy tasks
  -> Flask API connects privately to RDS PostgreSQL
```

## Placeholders to replace before deployment

Search the entire repository for:

```text
REPLACE_WITH_
```

You must replace every match before deploying.

### 1. Terraform remote state

File: `infra/versions.tf`

```hcl
bucket = "REPLACE_WITH_UNIQUE_TERRAFORM_STATE_BUCKET"
```

Replace it with your globally unique S3 state bucket name, for example:

```text
ahmed-terraform-state-bh-2026
```

### 2. ECS task definition

File: `ecs/task-definition.json`

| Placeholder | Replace with |
|---|---|
| `REPLACE_WITH_ECS_EXECUTION_ROLE_ARN` | ECS task execution role ARN |
| `REPLACE_WITH_ECS_TASK_ROLE_ARN` | ECS task role ARN |
| `REPLACE_WITH_ECR_IMAGE` | Full ECR image URI |
| `REPLACE_WITH_RDS_ENDPOINT` | RDS PostgreSQL endpoint |
| `REPLACE_WITH_SECRET_ARN` | Secrets Manager secret ARN |

After running `terraform apply`, get these values from Terraform outputs:

```bash
cd infra
terraform output
```

Example ECR image value:

```text
123456789012.dkr.ecr.eu-central-1.amazonaws.com/aws-ecs-flask-devsecops:abc123
```

### 3. GitHub Actions secrets

Go to:

```text
GitHub repository -> Settings -> Secrets and variables -> Actions -> New repository secret
```

Create:

| Secret | Value |
|---|---|
| `AWS_REGION` | For example, `eu-central-1` |
| `AWS_DEPLOY_ROLE_ARN` | GitHub OIDC deployment role ARN |
| `ECR_REPOSITORY` | `aws-ecs-flask-devsecops` |
| `ECS_CLUSTER_NAME` | `aws-ecs-flask-devsecops-cluster` |
| `ECS_SERVICE_NAME` | `aws-ecs-flask-devsecops-api` |

Use GitHub OIDC and a least-privilege IAM role; do not store long-lived AWS access keys in GitHub.

## Local development

```bash
docker compose up --build
curl http://localhost:8000/health
curl http://localhost:8000/ready
```

## Deployment order

1. Create the Terraform state S3 bucket and DynamoDB lock table.
2. Replace the S3 bucket placeholder in `infra/versions.tf`.
3. Run:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

4. Copy Terraform outputs into `ecs/task-definition.json`.
5. Add the GitHub Actions secrets.
6. Push the project to GitHub.
7. Push to `main`; GitHub Actions builds, scans, publishes, and deploys the image.

## Security controls

- Multi-AZ VPC with public, private application, and isolated database subnets
- ALB as the only internet-facing entry point
- Security-group chaining: ALB -> Flask API -> RDS
- Private ECS Fargate tasks and private RDS
- Secrets Manager with customer-managed KMS encryption
- Least-privilege IAM execution-role policy
- Non-root Docker user
- ECR scan-on-push
- Trivy and Checkov CI security scans
- ECS deployment circuit breaker with rollback

## API endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Application health check |
| GET | `/ready` | Database readiness check |
| GET | `/users` | Returns users from PostgreSQL |
