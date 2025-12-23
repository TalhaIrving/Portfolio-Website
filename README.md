# Portfolio Website – Cloud & DevOps Project

This project is a personal portfolio website designed to demonstrate practical cloud engineering and DevOps skills using AWS, Terraform, and GitHub Actions. The site is a static website served securely over HTTPS and deployed automatically through a CI/CD pipeline.

## Overview

The portfolio showcases:

* Infrastructure as Code using Terraform
* Secure AWS architecture for static website hosting
* Automated CI/CD for content deployment
* Modern authentication practices using GitHub OIDC
* Explicit separation between application deployment and infrastructure changes

The project intentionally mirrors real-world production decision-making rather than over-automation.

## Architecture

The website is hosted on AWS using the following services:

* Amazon S3 for static website storage
* Amazon CloudFront as a CDN in front of S3
* AWS Certificate Manager (ACM) for TLS certificates
* Amazon Route 53 for DNS management

Traffic flow:

1. User requests the site via a custom domain.
2. Route 53 routes traffic to CloudFront.
3. CloudFront serves cached content or retrieves it from S3.
4. All traffic is served over HTTPS.

## Repository Structure

```
.
├── infrastructure/
│   ├── Terraform configuration files
│   └── Remote backend configuration (S3 + DynamoDB)
├── website/
│   └── Static site files (HTML, CSS, assets)
├── .github/
│   └── workflows/
│       └── deploy-site.yml
├── .gitignore
├── LICENSE
└── README.md
```

## Infrastructure as Code (Terraform)

All AWS infrastructure is provisioned and managed using Terraform.

Provisioned resources include:

* S3 bucket for static site hosting
* CloudFront distribution
* ACM certificate (issued in us-east-1)
* Route 53 hosted zone and alias records
* IAM roles and policies
* GitHub OIDC provider

### Terraform State Management

Terraform state is stored remotely in:

* Amazon S3 for durable state storage
* DynamoDB for state locking

This prevents concurrent modifications and ensures the state remains consistent and recoverable.

## CI/CD Pipeline

### Design Philosophy

The CI/CD pipeline is intentionally hybrid:

* Application (static content) deployments are fully automated.
* Infrastructure changes are manual and explicitly controlled.

This mirrors production best practices where infrastructure changes are higher risk than application updates.

### Authentication (OIDC)

GitHub Actions authenticates to AWS using OpenID Connect (OIDC).

Key points:

* No AWS access keys are stored in GitHub Secrets.
* GitHub Actions requests short-lived credentials at runtime.
* AWS IAM issues temporary credentials via STS.
* Access is restricted to this repository and the `main` branch.

This eliminates long-lived credentials and reduces the blast radius of any potential compromise.

### Static Site Deployment (Automated)

Trigger:

* Push to the `main` branch.

Process:

* Syncs the `website/` directory to the S3 bucket.
* Creates a CloudFront cache invalidation.

Result:

* Content changes are deployed automatically.
* Updates are visible within seconds without manual intervention.

### Infrastructure Validation (Optional CI)

Terraform validation can be run automatically to:

* Format Terraform files
* Validate syntax
* Generate a plan showing proposed changes

These steps are non-destructive and do not modify infrastructure.

### Infrastructure Deployment (Manual)

Terraform applies are performed manually from a local environment.

Reasoning:

* Infrastructure changes are high-impact operations.
* Manual applies ensure human review before execution.
* Prevents accidental deletion or modification of critical resources via CI.

This decision is intentional and documented, not a limitation.

## IAM Security Model

IAM permissions follow a strict least-privilege approach.

GitHub Actions role permissions:

* Write access limited to S3 object uploads and CloudFront invalidations.
* Read-only access sufficient for Terraform state refresh and drift detection.
* No permissions to create or destroy unrelated AWS services.

## Deployment Workflow Summary

1. Infrastructure changes:

   * Modify Terraform files locally
   * Run `terraform plan` and review changes
   * Apply changes manually with `terraform apply`

2. Content changes:

   * Modify files in the `website/` directory
   * Commit and push to `main`
   * GitHub Actions deploys changes automatically

## Purpose

This project is designed to demonstrate:

* Realistic cloud architecture decisions
* Secure CI/CD design
* Modern AWS authentication patterns
* Clear separation of responsibilities between automation and control

It prioritizes correctness, security, and clarity over unnecessary complexity.

---


---

## Author

**[Your Name]**
Cloud & DevOps Engineer

---

This infrastructure was engineered to reflect the expectations of modern cloud platform roles, prioritising reliability, security, and automation over simplified tutorial deployments.
