resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy-site"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_oidc_provider.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:TalhaIrving/Portfolio-Website:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "deploy_site" {
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.website_domain}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${var.website_domain}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::talha-irving-terraform-state"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::talha-irving-terraform-state/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:eu-west-2:026090525608:table/terraform_lock"
      },
      # --- NEW READ PERMISSIONS ADDED BELOW ---
      {
        Effect = "Allow"
        Action = [
"iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:ListRolePolicies",         # Added
          "s3:GetBucketPolicy",
          "s3:GetBucketWebsite",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",             # Added
          "cloudfront:GetOriginAccessControl",
          "cloudfront:GetDistribution",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate"   # Added for Cert tags
        ]
        Resource = "*"
      }
    ]
  })
}