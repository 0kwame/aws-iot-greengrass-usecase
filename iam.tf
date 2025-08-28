# 1. IAM Role: Trust EC2
resource "aws_iam_role" "gg_instance_role" {
  name                  = "GreengrassCoreInstanceRole-${random_string.suffix.result}"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "gg_token_exchange_role" {
  name                  = "GreengrassV2TokenExchangeRole-${random_string.suffix.result}"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "credentials.iot.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gg_iot_full" {
  role       = aws_iam_role.gg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTFullAccess"
}

resource "aws_iam_role_policy_attachment" "gg_resource_access" {
  role       = aws_iam_role.gg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGreengrassResourceAccessRolePolicy"
}

resource "aws_iam_instance_profile" "gg_instance_profile" {
  name = "GreengrassCoreInstanceProfile-${random_string.suffix.result}"
  role = aws_iam_role.gg_instance_role.name
}

resource "aws_iam_role_policy_attachment" "gg_token_exchange_attach" {
  role       = aws_iam_role.gg_token_exchange_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGreengrassResourceAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "gg_s3_attach" {
  role       = aws_iam_role.gg_token_exchange_role.name
  policy_arn = aws_iam_policy.gg_s3_policy.arn
}


resource "aws_iam_policy" "gg_s3_policy" {
  name        = "GreengrassS3Policy-${random_string.suffix.result}"
  description = "Allow Greengrass to fetch component artifacts from S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::greengrass-components-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::greengrass-components-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}

# resource "aws_iam_role_policy" "gg_role_s3_policy" {
#   name = "GreengrassRoleS3Policy-${random_string.suffix.result}"
#   role = aws_iam_role.gg_instance_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:ListBucket"
#         ],
#         Resource = [
#           "arn:aws:s3:::greengrass-components-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}",
#           "arn:aws:s3:::greengrass-components-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}/*"
#         ]
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy" "gg_e2e_permissions" {
  name = "GreengrassBootstrapPermissions-${random_string.suffix.result}"
  role = aws_iam_role.gg_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "MinimalInstallerPermissions",
        Effect = "Allow",
        Action = [
          "iot:CreateThing",
          "iot:CreateThingGroup",
          "iot:CreatePolicy",
          "iot:AttachThingPrincipal",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iot:DescribeEndpoint",
          "greengrass:CreateDeployment"
        ],
        Resource = "*"
      },
      {
        Sid    = "S3ReadArtifacts",
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::greengrass-components-eu-central-1-382828593864",
          "arn:aws:s3:::greengrass-components-eu-central-1-382828593864/*"
        ]
      }
    ]
  })
}


