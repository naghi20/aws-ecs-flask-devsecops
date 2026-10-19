# Flask API on AWS ECS Fargate with DevSecOps

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

## Security controls

- Private application subnets for ECS Fargate tasks
- Isolated database subnets for RDS
- ALB is the only internet-facing entry point
- Security-group chaining: ALB -> API -> RDS
- Secrets Manager and customer-managed KMS encryption for DB credentials
- Least-privilege IAM execution-role policy
- Non-root Docker container user
- ECR scan-on-push
- Trivy dependency and filesystem scanning
- Checkov Terraform IaC scanning
- ECS deployment circuit breaker with automatic rollback

## Local development

```bash
docker compose up --build
curl http://localhost:8000/health
```

## Deployment

1. Create an S3 bucket and DynamoDB table for Terraform remote state and locking.
2. Update `infra/versions.tf` with your state bucket name.
3. Create an OIDC GitHub Actions deploy role with least-privilege ECS/ECR permissions.
4. Set repository secrets: `AWS_REGION`, `AWS_DEPLOY_ROLE_ARN`, `ECR_REPOSITORY`, `ECS_CLUSTER_NAME`, and `ECS_SERVICE_NAME`.
5. Run:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

6. Push to `main`; GitHub Actions builds, scans, publishes, and deploys the image.

## API endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Container/application health check |
| GET | `/ready` | Database connectivity readiness check |
| GET | `/users` | Returns users from PostgreSQL |
